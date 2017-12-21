RSpec.describe HyperNavigator do

  it "has a version number" do
    expect(HyperNavigator::VERSION).not_to be nil
  end

  let(:doc_root) do
    <<-EOF
      { "links": [
        {"rel": "a", "href": "/a"}
      ]}
    EOF
  end

  let(:doc_a) do
    <<-EOF
      { "links": [
        {"rel": "b", "href": "/a/b"}
      ]}
    EOF
  end

  let(:doc_a_b) do
    <<-EOF
      { "links": [
        {"rel": "b1", "href": "/a/b1"},
        {"rel": "c", "href": "/a/b/c"},
        {"rel": "d", "href": "/a/b/c/d"}
      ]}
    EOF
  end

  let(:doc_a_b1) do
    <<-EOF
      { "links": [ ] }
    EOF
  end

  let(:doc_a_b_c) do
    <<-EOF
      { "links": [
        {"rel": "d", "href": "/a/b/c/d"}
      ]}
    EOF
  end

  let(:doc_a_b_c_d) do
    <<-EOF
      { "links": [ ] }
    EOF
  end

  describe "#surf" do
    it "returns all of the documents fetched during the surf" do

      allow(HyperNavigator).to receive(:get).with('/', {}).and_return(double(body: doc_root))
      allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(double(body: doc_a))
      allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(double(body: doc_a_b))
      allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(double(body: doc_a_b1))
      allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(double(body: doc_a_b_c))
      allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(double(body: doc_a_b_c_d))

      result = HyperNavigator.surf('/', nil).map {|x| x.href }
      expect(result).to include("/a", "/a/b", "/a/b1", "/a/b/c", "/a/b/c/d")
    end
  end

  describe "#surf" do
    it "returns only the documents in the given path" do

      allow(HyperNavigator).to receive(:get).with('/', {}).and_return(double(body: doc_root))
      allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(double(body: doc_a))
      allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(double(body: doc_a_b))
      allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(double(body: doc_a_b1))
      allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(double(body: doc_a_b_c))
      allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(double(body: doc_a_b_c_d))

      result = HyperNavigator.surf('/', ["a", "b", "c" ,"d"]).map {|x| x.href }
      expect(result).to include("/a", "/a/b", "/a/b/c", "/a/b/c/d")
      expect(result).not_to include("/a/b1")
    end
  end

  describe "#surf_to_leaves" do
    it "returns just the leaf documents fetched during the surf" do
      allow(HyperNavigator).to receive(:get).with('/', {}).and_return(double(body: doc_root))
      allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(double(body: doc_a))
      allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(double(body: doc_a_b))
      allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(double(body: doc_a_b1))
      allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(double(body: doc_a_b_c))
      allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(double(body: doc_a_b_c_d))

      result = HyperNavigator.surf_to_leaves('/', nil).map {|x| x.href }
      expect(result).to include("/a/b1", "/a/b/c/d")
      expect(result).not_to include("/a", "/a/b", "/a/b/c")
    end

    it "returns just the leaf documents fetched for the given path" do
      allow(HyperNavigator).to receive(:get).with('/', {}).and_return(double(body: doc_root))
      allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(double(body: doc_a))
      allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(double(body: doc_a_b))
      allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(double(body: doc_a_b1))
      allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(double(body: doc_a_b_c))
      allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(double(body: doc_a_b_c_d))

      result = HyperNavigator.surf_to_leaves('/', ["a", "b", "c" ,"d"]).map {|x| x.href }
      expect(result).to include("/a/b/c/d")
      expect(result).not_to include("/a", "/a/b", "/a/b1", "/a/b/c")
    end

    it "returns just the leaf documents fetched for the given short path" do
      allow(HyperNavigator).to receive(:get).with('/', {}).and_return(double(body: doc_root))
      allow(HyperNavigator).to receive(:get).with('/a', {}).and_return(double(body: doc_a))
      allow(HyperNavigator).to receive(:get).with('/a/b', {}).and_return(double(body: doc_a_b))
      allow(HyperNavigator).to receive(:get).with('/a/b1', {}).and_return(double(body: doc_a_b1))
      allow(HyperNavigator).to receive(:get).with('/a/b/c', {}).and_return(double(body: doc_a_b_c))
      allow(HyperNavigator).to receive(:get).with('/a/b/c/d', {}).and_return(double(body: doc_a_b_c_d))

      result = HyperNavigator.surf_to_leaves('/', ["a", "b"]).map {|x| x.href }
      expect(result).to include("/a/b")
      expect(result).not_to include("/a", "/a/b1", "/a/b/c")
    end
  end
end
