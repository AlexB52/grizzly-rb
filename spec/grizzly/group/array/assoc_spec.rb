require_relative '../../../spec_helper'
require_relative 'fixtures/classes'

describe :collection_assoc, shared: true do
  it "returns the first array whose 1st item is == obj or nil" do
    s1 = ["colors", "red", "blue", "green"]
    s2 = [:letters, "a", "b", "c"]
    s3 = [4]
    s4 = ["colors", "cyan", "yellow", "magenda"]
    s5 = [:letters, "a", "i", "u"]
    s_nil = [nil, nil]
    a = @subject.new([s1, s2, s3, s4, s5, s_nil])
    a.assoc(s1.first).should equal(s1)
    a.assoc(s2.first).should equal(s2)
    a.assoc(s3.first).should equal(s3)
    a.assoc(s4.first).should equal(s1)
    a.assoc(s5.first).should equal(s2)
    a.assoc(s_nil.first).should equal(s_nil)
    a.assoc(4).should equal(s3)
    a.assoc("key not in array").should be_nil
  end

  it "calls == on first element of each array" do
    key1 = 'it'
    key2 = mock('key2')
    items = @subject.new([['not it', 1], [CollectionSpecs::AssocKey.new, 2], ['na', 3]])

    items.assoc(key1).should equal(items[1])
    items.assoc(key2).should be_nil
  end

  it "ignores any non-Array elements" do
    @subject.new([1, 2, 3]).assoc(2).should be_nil
    s1 = [4]
    s2 = [5, 4, 3]
    a = @subject.new(["foo", [], s1, s2, nil, []])
    a.assoc(s1.first).should equal(s1)
    a.assoc(s2.first).should equal(s2)
  end
end

describe "Array#assoc" do
  before { @subject = Array }

  it_behaves_like :collection_assoc, :assoc
end

describe "Collection#assoc" do
  before { @subject = Group }

  it_behaves_like :collection_assoc, :assoc
end