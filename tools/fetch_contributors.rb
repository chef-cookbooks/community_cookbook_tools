#!/usr/bin/env ruby

unless ENV['GITHUB_TOKEN']
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

  connection = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  connection.auto_paginate = true
  connection.middleware = faraday
  connection
end

def chef_employee(user)
  return true if user["company"].match?(/chef|opscode|habitat/i)
  return true if user["email"].match?(/chef|opscode|habitat/i)
  return true if user["login"].match?(/msys/i) # msys contractors
  return true if user["email"].match?(/opscode\.com|chef\.io|getchef\.com|habitat\sh/i) # company isn't chef, but e-mail is
  # weed out some known employees I found
  return true if %w(jonsmorrow kagarmoe robbkidd jeremiahsnapp chef-delivery NAshwini chris-rock hannah-radish tyler-ball wrightp TheLunaticScripter).include? user["login"]
rescue NoMethodError
  false
end

def fetch_prs(org)
  puts "\nFetching all users that have opened PRs against the org #{org} in the last year. This may take a long while...\n\n"
  users = {}
  # fetch any issue ever created that's in any state and don't filter anything
  connection.org_issues(org, state: "all", filter: "all", sort: "created", since: DateTime.now - 365).each do |issue|

    # we're not doing this for private repos
    next if issue[:repository][:private] == true

    # skip issues
    next unless issue[:pull_request]

    # the filter returns old PRs that have been updated recently. Those dont' count
    next if DateTime.parse(issue["created_at"].to_s) < DateTime.now - 365

    if @ignore_cheffers
      next if chef_employee(connection.user(issue["user"]["login"]))
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
    users[issue["user"]["login"]]["repos"] << issue["repository"]["name"] unless users[issue["user"]["login"]]["repos"].include?(issue["repository"]["name"])
  end

  users.sort_by { |k, v| v["contributions"] }.reverse.to_h
end

if ARGV.empty?
  puts "You must pass the org to fetch contributors for!"
  exit!
end

fetch_prs(ARGV.first).each_value do |user|
  puts "#{user['username']},#{user['name']},#{user['e-mail']},#{user['company'].delete(',') rescue nil},#{user['contributions']},#{user['repos'].join(' ')}"
end
