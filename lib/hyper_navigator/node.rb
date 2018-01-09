require 'net/http'
require 'uri'
require 'json'

module HyperNavigator

  def self.get(href, headers={})
    uri = URI.parse(href)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri, headers)

    http.request(request)
  end

  def self.post(href, body, headers={})
    uri = URI.parse(href)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body

    http.request(request)
  end

  class PatternMatcher

    def initialize(headers,opts={})
      @opts = opts
      @headers = headers
    end

    def match(href, exp)
      match_here(exp, Node.new(:root, href, @headers, 0))
    end

    def match_here(exp, node)
      if exp == nil
        return node
      elsif exp[1] == :star
        match_star(exp[0], exp.drop(2), node)
        return node
      elsif exp[0] == :any
        match_here_descendants(exp, node)
        return node
      elsif exp[0] == node.rel
        match_here_descendants(exp, node)
        return node
      end
      return NullNode.new
    end

    def match_here_descendants(exp, node)
      links = node.links.map {|link| make_node(link, node.depth + 1)}
      descendants = links.map {|n| match_here(exp.drop(1), n) }
      node.descendants = descendants.select {|d| d.class == Node }
    end

    def match_star(exp_star, exp, node)
      # in case of zero matches, exp can match here
      node_here = match_here(exp, node)

      if node_here.is_a? NullNode
        match_star_descendants(exp_star, exp, node)
      end
    end

    def match_star_descendants(exp_star, exp, node)
      if exp_star == :any
        links = node.links
      else
        links = node.links.select { |link| link["rel"] == exp_star }
      end

      node.descendants = links.map { |link| make_node(link, node.depth + 1) }
      node.descendants.map {|desc| match_star(exp_star, exp, desc) }
    end

    def make_node(link, depth=nil)
      padding = '  ' * depth
      puts "#{padding}#{link}" if @opts[:verbose]
      Node.new(link["rel"], link["href"], @headers, depth)
    end

  end

  class Node

    IGNORE_REFS = ["self", "up", "next", "prev"]

    attr_reader :rel, :href, :headers, :response
    attr_accessor :descendants, :depth

    def initialize(rel, href, headers={}, depth=nil)
      @rel = rel
      @href = href
      @headers = headers
      @descendants = []
      @depth = depth
      if href
        @response = HyperNavigator.get(href, headers)
        raise RuntimeError, @response unless @response.code =~ /^2..$/
      end
    end

    def links
      @cached_links ||= begin
        json = JSON.parse(@response.body) rescue nil
        return [] unless json
        json["links"].reject do |i|
          IGNORE_REFS.any? { |r| r == i["rel"] }
        end
      end
    end

    def flatten_branch
      descendants + descendants.flat_map { | d| d.flatten_branch }
    end

  end

  class NullNode < Node
    def initialize()
      super(nil, nil)
    end
  end
end
