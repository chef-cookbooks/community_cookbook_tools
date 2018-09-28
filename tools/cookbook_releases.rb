#!/usr/bin/env ruby

require "net/http"
require "json"
require "date"

def cookbooks
  uri = URI("https://supermarket.chef.io/api/v1/users/chef")
  response = Net::HTTP.get(uri)
  JSON.parse(response)["cookbooks"]["owns"].keys
end

def versions(cb_name)
  uri = URI("https://supermarket.chef.io/api/v1/cookbooks/#{cb_name}")
  response = Net::HTTP.get(uri)
  JSON.parse(response)["versions"].map! { |x| x.split("/")[-1] }
end

def cb_version_publish_date(cb, version)
  uri = URI("https://supermarket.chef.io/api/v1/cookbooks/#{cb}/versions/#{version}")
  response = Net::HTTP.get(uri)
  DateTime.parse(JSON.parse(response)["published_at"])
end

def deprecated_date(cb)
  uri = URI("https://supermarket.chef.io/api/v1/cookbooks/#{cb}")
  response = JSON.parse(Net::HTTP.get(uri))
  return DateTime.parse(response["updated_at"]) if response["deprecated"]
end

if ARGV.empty?
  puts "You must pass two dates in format: 2017-10-01"
  exit!
end

since_date = DateTime.parse(ARGV.first)
till_date = DateTime.parse(ARGV[1] ? ARGV[1] : Time.now)
verbose = ARGV[2] == "-v" ? true : false
releases = []
deprecated = []

cookbooks.each do |cb|
  puts "Checking #{cb} deprecation status"
  dep_date = deprecated_date(cb)
  deprecated << cb if dep_date && dep_date >= since_date && dep_date <= till_date

  versions(cb).each do |version|
    puts "Checking #{cb} version #{version} release date"
    pub_date = cb_version_publish_date(cb, version)
    if pub_date >= since_date && pub_date <= till_date
      releases << { cb => version }
    else
      break
    end
  end
end

puts "\nThere have been #{releases.count} cookbook releases between #{since_date} and #{till_date}"
puts "\nThere have been #{deprecated.count} cookbooks deprecated between #{since_date} and #{till_date}"

return unless verbose
puts "\nReleases:"
releases.each do |c|
  puts "#{c.keys.first} #{c.values.first}"
end
