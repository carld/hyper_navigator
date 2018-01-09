require "hyper_navigator/version"
require "hyper_navigator/node"

module HyperNavigator

  def self.surf(root_url, exp, headers={}, options={})
    PatternMatcher.new(headers, options).match(root_url, exp).flatten_branch
  end

end