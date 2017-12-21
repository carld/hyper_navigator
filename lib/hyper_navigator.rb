require "hyper_navigator/version"
require "hyper_navigator/node"

module HyperNavigator

  def self.surf(home, path=nil, headers={})
    root = Node.new('rel', home, nil, 0, path, headers)
    nodes = lambda do |node|
      node.descendants + node.descendants.flat_map {|d| nodes.call(d) }
    end
    nodes.call(root)
  end

  def self.surf_to_leaves(home, path=nil, headers={})
    root = Node.new('rel', home, nil, 0, path, headers)
    nodes = lambda do |node|
      if node.descendants.empty?
        node
      else
        node.descendants.flat_map {|d| nodes.call(d) }
      end
    end
    nodes.call(root)
  end

end