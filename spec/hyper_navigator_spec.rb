RSpec.describe HyperNavigator do

  it "has a version number" do
    expect(HyperNavigator::VERSION).not_to be nil
  end

  # (root)
  #  `--(a)
  #      `--(b)
  #          `--(b1)
  #          `--(c)
  #          `---`--(d)

  let(:doc_root) do
    # root
    <<-EOF
      { "links": [
        {"rel": "a", "href": "/a"}
      ]}
    EOF
  end

  let(:doc_a) do
    # a
    <<-EOF
      { "links": [
        {"rel": "b", "href": "/a/b"}
      ]}
    EOF
  end

  let(:doc_a_b) do
    # b
    <<-EOF
      { "links": [
        {"rel": "b1", "href": "/a/b1"},
        {"rel": "c", "href": "/a/b/c"},
        {"rel": "d", "href": "/a/b/c/d"}
      ]}
    EOF
  end

  let(:doc_a_b1) do
    # b1
    <<-EOF
      { "links": [ ] }
    EOF
  end

  let(:doc_a_b_c) do
    # c
    <<-EOF
      { "links": [
        {"rel": "d", "href": "/a/b/c/d"}
      ]}
    EOF
  end

  let(:doc_a_b_c_d) do
    # d
    <<-EOF
      { "links": [ ] }
    EOF
  end

  before do
    allow(HyperNavigator).to receive(:get).with('/', {}).and_return(OpenStruct.new(body: doc_root, code: '200'))
    allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(OpenStruct.new(body: doc_a, code: '200'))
    allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(OpenStruct.new(body: doc_a_b, code: '200'))
    allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(OpenStruct.new(body: doc_a_b1, code: '200'))
    allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(OpenStruct.new(body: doc_a_b_c, code: '200'))
    allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(OpenStruct.new(body: doc_a_b_c_d, code: '200'))
  end

  describe "#surf" do

    it "returns all of the documents given a path with any match:  ['a', :any]" do
      result = HyperNavigator.surf('/', ['root', 'a', :any]).map {|x| x.href }
      expect(result).to include('/a', '/a/b')
      expect(result).not_to include('/a/b1', '/a/b/c', '/a/b/c/d')
    end

    it "returns all of the documents given a Kleene star path:  [:any, :star] " do
      result = HyperNavigator.surf('/', [:any, :star]).map {|x| x.href }
      expect(result).to include('/a', '/a/b', '/a/b1', '/a/b/c', '/a/b/c/d')
    end

    it "returns all of the documents given a Kleene star path:  [:any, :any] " do
      result = HyperNavigator.surf('/', [:any, :any, :any]).map {|x| x.href }
      expect(result).to include('/a', '/a/b')
      expect(result).not_to include('/a/b1', '/a/b/c', '/a/b/c/d')
    end

    it "returns only the documents in the given path:  ['a', 'b', 'c' ,'d'] " do
      result = HyperNavigator.surf('/', ['root', 'a', 'b', 'c' , 'd']).map {|x| x.href }
      expect(result).to include('/a', '/a/b', '/a/b/c', '/a/b/c/d')
      expect(result).not_to include('/a/b1')
    end

    it "returns only the documents in the given path:  ['root', a', 'b', 'c'] " do
      result = HyperNavigator.surf('/', ['root', 'a', 'b', 'c']).map {|x| x.href }
      expect(result).to include('/a', '/a/b', '/a/b/c')
      expect(result).not_to include('/a/b1', '/a/b/c/d')
    end

    it "returns only the documents in the given Kleene star path:  [:any, :star, 'b']" do
      result = HyperNavigator.surf('/', [:any, :star, 'b']).map {|x| x.href }
      expect(result).to include('/a', '/a/b')
      expect(result).not_to include('/a/b1', '/a/b/c', '/a/b/c/d')
    end

  end

end
