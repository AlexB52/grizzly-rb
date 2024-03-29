require_relative '../../../spec_helper'
require_relative 'fixtures/classes'

describe :collection_rassoc, shared: true do
  it "returns the first contained array whose second element is == object" do
    ary = @subject.new([[1, "a", 0.5], [2, "b"], [3, "b"], [4, "c"], [], [5], [6, "d"]])
    ary.rassoc("a").should == [1, "a", 0.5]
    ary.rassoc("b").should == [2, "b"]
    ary.rassoc("d").should == [6, "d"]
    ary.rassoc("z").should == nil
  end

  it "properly handles recursive arrays" do
    empty = CollectionSpecs.empty_recursive_array(@subject)
    empty.rassoc([]).should be_nil
    [[empty, empty]].rassoc(empty).should == [empty, empty]

    array = CollectionSpecs.recursive_array(@subject)
    array.rassoc(array).should be_nil
    [[empty, array]].rassoc(array).should == [empty, array]
  end

  it "calls elem == obj on the second element of each contained array" do
    key = 'foobar'
    o = mock('foobar')
    def o.==(other); other == 'foobar'; end

    @subject.new([[1, :foobar], [2, o], [3, mock('foo')]]).rassoc(key).should == [2, o]
  end

  it "does not check the last element in each contained but specifically the second" do
    key = 'foobar'
    o = mock('foobar')
    def o.==(other); other == 'foobar'; end

    @subject.new([[1, :foobar, o], [2, o, 1], [3, mock('foo')]]).rassoc(key).should == [2, o, 1]
  end
end

describe "Array#rassoc" do
  before { @subject = Array }

  it_behaves_like :collection_rassoc, :rassoc
end

describe "Collection#rassoc" do
  before { @subject = Group }

  it_behaves_like :collection_rassoc, :rassoc
end