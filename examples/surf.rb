#!/usr/bin/env ruby

require "bundler/setup"
require "optparse"
require "ostruct"
require "hyper_navigator"
require "pp"

options = OpenStruct.new
options.verbose = false

OptionParser.new do |opts|
  opts.banner ="Usage: #{ARGV[0]} [options]"
  opts.on("-uURL", "--root-url=URL", "required root URL") do |url|
    options.url = url
  end
  opts.on("-pPATTERN", "--pattern=PATTERN", "required traversal pattern") do |pattern|
    options.pattern = eval(pattern)
  end
  opts.on("-a[AUTH_URL]", "--auth-url=[AUTH_URL]") do |url|
    options.auth_url = url
  end
  opts.on("-v", "--verbose") do |v|
    options.verbose = true
  end
end.parse!

CLIENT_ID=ENV['CLIENT_ID']
CLIENT_SECRET=ENV['CLIENT_SECRET']

if options.auth_url
  headers = {"Content-type" => "application/x-www-form-urlencoded"}
  body = URI.encode_www_form(
    "client_id" => CLIENT_ID,
    "client_secret" => CLIENT_SECRET,
    "grant_type" => "client_credentials",
    "response_type" => "code")
  response = HyperNavigator.post(options.auth_url, body, headers)
  json = JSON.parse(response.body)
  $token = json['id_token']
  options.headers = { "Authorization" => "Bearer #{$token}" }
else
  options.headers = {}
end

result = HyperNavigator.surf(options.url, options.pattern, options.headers, { :verbose => options.verbose })

result.map do |n|
  pp JSON.parse(n.response.body) rescue nil
end