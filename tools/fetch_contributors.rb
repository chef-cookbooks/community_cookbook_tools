#!/usr/bin/env ruby

unless ENV["GITHUB_TOKEN"]
  puts "You must set the GITHUB_TOKEN environmental variable with a GitHub token!"
  exit 1
end

@ignore_cheffers = true

begin
  require "octokit"
  require "faraday-http-cache"
rescue LoadError
  puts "This script requires octokit and faraday-http-cache gems!"
end

require "date"
require "time"

def connection
  @client ||= setup_connection
end

def setup_connection
  faraday = Faraday::RackBuilder.new do |builder|
    builder.use Faraday::HttpCache
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
  end

  connection = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
  connection.auto_paginate = true
  connection.middleware = faraday
  connection
end

def chef_employee?(login)
  @not_employees ||= []
  # start with a few users that aren't matched by the below logic, but totally work at Chef or worked at Chef recently
  @employees ||= %w(jonsmorrow kagarmoe robbkidd jeremiahsnapp chef-delivery NAshwini chris-rock hannah-radish tyler-ball wrightp TheLunaticScripter miah chef-ci nsdavidson jjasghar nathenharvey iennae)

  # don't bother further processing if we know their state
  return true if @employees.include?(login)
  return false if @not_employees.include?(login)

  if login.match?(/msys/i) # msys contractors
    @employees << login
    return true
  end

  # the following require looking up the user with Github first
  user = connection.user(login)
  if user["company"].match?(/chef|opscode|habitat|msystechnologies/i) ||
      user["email"].match?(/opscode\.com|chef\.io|getchef\.com|habitat\.sh/i)
    @employees << user["login"]
    return true
  end

  # assume not an employee now
  @not_employees << user["login"]
  false
rescue NoMethodError
  @not_employees << user["login"]
  false
end

def verbose?
  ARGV[2] == "-v" ? true : false
end

def fetch_prs(org)
  puts "\nFetching all users that have opened PRs against the org #{org} in the last year. This may take a long while...\n\n"
  users = {}
  repos = {}
  pr_count = 0
  # fetch any issue ever created that's in any state and don't filter anything

  connection.organization_repositories(org, {:type => 'public'}).each do |repo|
    puts "we're in #{repo['full_name']}" if verbose?

    connection.pull_requests(repo['full_name'], {:state => 'all'}).each do |issue|
      # The result set is sorted from new to old so if we hit one older than a year
      # we can break and move onto the next repo
      puts "The issue is from #{issue['created_at']}" if verbose?
      #require 'pry'; binding.pry
      break if DateTime.parse(issue['created_at'].to_s) < ( DateTime.now - 365 )

      if @ignore_cheffers
        puts "#{issue["user"]["login"]} is an employee?: #{chef_employee?(issue["user"]["login"])}" if verbose?
        next if chef_employee?(issue["user"]["login"])
      end

      # don't count PRs we never merged
      next if issue['closed'] && issue['merged_at'].nil?

      # bump the total PR count
      pr_count += 1

      # bump the repo PR count.
      if repos[repo['name']]
        repos[repo['name']] += 1
      else
        repos[repo['name']] = 1
      end

      # add the user to the hash with several attributes
      unless users[issue["user"]["login"]]
        users[issue["user"]["login"]] = {}
        users[issue["user"]["login"]]["repos"] = []
        users[issue["user"]["login"]]["contributions"] = 0
        users[issue["user"]["login"]]["username"] = issue["user"]["login"]

        user_details = connection.user(issue["user"]["login"])
        users[issue["user"]["login"]]["e-mail"] = user_details["email"]
        users[issue["user"]["login"]]["name"] = user_details["name"]
        users[issue["user"]["login"]]["company"] = user_details["company"]
      end
      users[issue["user"]["login"]]["contributions"] += 1
      users[issue["user"]["login"]]["repos"] << repo['full_name'] unless users[issue["user"]["login"]]["repos"].include?(repo['full_name'])
    end
  end

  return users.sort_by { |_k, v| v["contributions"] }.reverse.to_h, repos, pr_count
end

if ARGV.empty?
  puts "You must pass the org to fetch contributors for!"
  exit!
end

users, repos, pr_count = fetch_prs(ARGV.first)

puts "\n\nCONTRIBUTOR STATS\n\n"
users.each_value do |user|
  puts "#{user['username']},#{user['name']},#{user['e-mail']},#{begin
                                                                  user['company'].delete(',')
                                                                rescue
                                                                  nil
                                                                end},#{user['contributions']},#{user['repos'].join(' ')}"
end

puts "\n\nREPO PR COUNTS\n\n"
repos.each do |k,v|
  puts "#{k}, #{v}"
end

puts "\n\nTOTAL PR COUNT\n\n"
puts pr_count
