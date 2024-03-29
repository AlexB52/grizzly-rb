require_relative '../../../spec_helper'
require_relative 'fixtures/classes'
require_relative 'shared/enumerable_enumeratorized'

describe :collection_sort_by, shared: true do
  it "returns an array of elements ordered by the result of block" do
    a = @subject.new(EnumerableSpecs::Numerous.new("once", "upon", "a", "time"))
    a.sort_by { |i| i[0] }.should == ["a", "once", "time", "upon"]
  end

  it "sorts the object by the given attribute" do
    a = EnumerableSpecs::SortByDummy.new("fooo")
    b = EnumerableSpecs::SortByDummy.new("bar")

    ar = @subject.new([a, b]).sort_by { |d| d.s }
    ar.should == [b, a]
  end

  it "returns an Enumerator when a block is not supplied" do
    a = @subject.new(EnumerableSpecs::Numerous.new("a","b"))
    a.sort_by.should be_an_instance_of(Enumerator)
    a.to_a.should == ["a", "b"]
  end

  # it "gathers whole arrays as elements when each yields multiple" do
  #   multi = EnumerableSpecs::YieldsMulti.new
  #   multi.sort_by {|e| e.size}.should == [[1, 2], [3, 4, 5], [6, 7, 8, 9]]
  # end

  # it "returns an array of elements when a block is supplied and #map returns an enumerable" do
  #   b = EnumerableSpecs::MapReturnsEnumerable.new
  #   b.sort_by{ |x| -x }.should == [3, 2, 1]
  # end

  it "calls #each to iterate over the elements to be sorted" do
    b = @subject.new(EnumerableSpecs::Numerous.new( 1, 2, 3 ))
    b.should_receive(:each).once.and_yield(1).and_yield(2).and_yield(3)
    b.should_not_receive :map
    b.sort_by { |x| -x }.should == [3, 2, 1]
  end

  # it_behaves_like :enumerable_enumeratorized_with_origin_size, :sort_by
end

describe "Array#sort_by" do
  before { @subject = Array }

  it_behaves_like :collection_sort_by, :sort_by

  it "doesn't return instance on Array subclasses" do
    class MyArray < Array;end
    MyArray.new([1,2,3,4]).sort_by { |i| i }.should be_an_instance_of(Array)
  end
end

describe "Collection#sort_by" do
  before { @subject = Group }

  it_behaves_like :collection_sort_by, :sort_by

  it "returns subclass instance on Array subclasses" do
    Group.new([1,2,3,4]).sort_by { |i| i }.should be_an_instance_of(Group)
  end
end
