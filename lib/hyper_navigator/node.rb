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

  class Node

    attr_reader :ancestor, :descendants, :rel, :href, :depth, :response, :path

    def initialize(rel, href, ancestor=nil, depth=nil, path=nil, headers={})
      @ancestor = ancestor
      @descendants = []
      @rel = rel
      @href = href
      @depth = depth
      @path = path
      @headers = headers

      @response = HyperNavigator.get(href, headers)
      @descendants = follow_links
    end

    private

    def links
      json = JSON.parse(@response.body) rescue nil
      return [] unless json
      # If we've been given a path then only follow the links in the path
      if @path
        json["links"].select { |link| link["rel"] == @path.first }
      else
        json["links"].reject {|i| ["self","up","next","prev"].any?{|r| r == i["rel"]} }
      end
    end

    def next_step
      return @path.drop(1) if @path
      nil
    end

    def follow_links
      links.map do |link|
        Node.new(link["rel"], link["href"], self, @depth + 1, next_step, @headers)
      end
    end

  end
end