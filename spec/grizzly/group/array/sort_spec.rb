require_relative '../../../spec_helper'
require_relative 'fixtures/classes'


describe :collection_sort, shared: true do
  it "returns a new array sorted based on comparing elements with <=>" do
    a = @subject.new([1, -2, 3, 9, 1, 5, -5, 1000, -5, 2, -10, 14, 6, 23, 0])
    a.sort.should == [-10, -5, -5, -2, 0, 1, 1, 2, 3, 5, 6, 9, 14, 23, 1000]
  end

  it "does not affect the original Array" do
    a = @subject.new([3, 1, 2])
    a.sort.should == [1, 2, 3]
    a.should == [3, 1, 2]

    a = @subject.new([0, 15, 2, 3, 4, 6, 14, 5, 7, 12, 8, 9, 1, 10, 11, 13])
    b = a.sort
    a.should == [0, 15, 2, 3, 4, 6, 14, 5, 7, 12, 8, 9, 1, 10, 11, 13]
    b.should == (0..15).to_a
  end

  it "sorts already-sorted Arrays" do
    @subject.new((0..15).to_a).sort.should == (0..15).to_a
  end

  it "sorts reverse-sorted Arrays" do
    @subject.new((0..15).to_a).reverse.sort.should == (0..15).to_a
  end

  it "sorts Arrays that consist entirely of equal elements" do
    a = @subject.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
    a.sort.should == a
    b = Array.new(15).map { CollectionSpecs::SortSame.new }
    b.sort.should == b
  end

  it "sorts Arrays that consist mostly of equal elements" do
    a = @subject.new([1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1])
    a.sort.should == [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  end

  it "does not return self even if the array would be already sorted" do
    a = @subject.new([1, 2, 3])
    sorted = a.sort
    sorted.should == a
    sorted.should_not equal(a)
  end

  it "properly handles recursive arrays" do
    empty = CollectionSpecs.empty_recursive_array(@subject)
    empty.sort.should == empty

    array = [[]]; array << array
    array.sort.should == [[], array]
  end

  it "uses #<=> of elements in order to sort" do
    a = CollectionSpecs::MockForCompared.new
    b = CollectionSpecs::MockForCompared.new
    c = CollectionSpecs::MockForCompared.new

    CollectionSpecs::MockForCompared.compared?.should == false
    @subject.new([a, b, c]).sort.should == [c, b, a]
    CollectionSpecs::MockForCompared.compared?.should == true
  end

  it "does not deal with exceptions raised by unimplemented or incorrect #<=>" do
    o = Object.new

    -> {
      @subject.new([o, 1]).sort
    }.should raise_error(ArgumentError)
  end

  it "may take a block which is used to determine the order of objects a and b described as -1, 0 or +1" do
    a = @subject.new([5, 1, 4, 3, 2])
    a.sort.should == [1, 2, 3, 4, 5]
    a.sort {|x, y| y <=> x}.should == [5, 4, 3, 2, 1]
  end

  it "raises an error when a given block returns nil" do
    -> { @subject.new([1, 2]).sort {} }.should raise_error(ArgumentError)
  end

  # New Interface
  # it "does not call #<=> on contained objects when invoked with a block" do
  #   a = @subject.new(Array.new(25))
  #   (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

  #   a.sort { -1 }.should be_an_instance_of(Array)
  # end

  # it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
  #   a = @subject.new(Array.new(1500))
  #   (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

  #   a.sort { -1 }.should be_an_instance_of(Array)
  # end

  # it "completes when supplied a block that always returns the same result" do
  #   a = @subject.new([2, 3, 5, 1, 4])
  #   a.sort {  1 }.should be_an_instance_of(Array)
  #   a.sort {  0 }.should be_an_instance_of(Array)
  #   a.sort { -1 }.should be_an_instance_of(Array)
  # end

  it "does not freezes self during being sorted" do
    a = @subject.new([1, 2, 3])
    a.sort { |x,y| a.frozen?.should == false; x <=> y }
  end

  it "returns the specified value when it would break in the given block" do
    @subject.new([1, 2, 3]).sort{ break :a }.should == :a
  end

  it "uses the sign of Bignum block results as the sort result" do
    a = @subject.new([1, 2, 5, 10, 7, -4, 12])
    begin
      class Bignum;
        alias old_spaceship <=>
        def <=>(other)
          raise
        end
      end
      a.sort {|n, m| (n - m) * (2 ** 200)}.should == [-4, 1, 2, 5, 7, 10, 12]
    ensure
      class Bignum
        alias <=> old_spaceship
      end
    end
  end

  it "compares values returned by block with 0" do
    a = @subject.new([1, 2, 5, 10, 7, -4, 12])
    a.sort { |n, m| n - m }.should == [-4, 1, 2, 5, 7, 10, 12]
    a.sort { |n, m|
      CollectionSpecs::ComparableWithFixnum.new(n-m)
    }.should == [-4, 1, 2, 5, 7, 10, 12]
    -> {
      a.sort { |n, m| (n - m).to_s }
    }.should raise_error(ArgumentError)
  end

  it "sorts an array that has a value shifted off without a block" do
    a = @subject.new(Array.new(20, 1))
    a.shift
    a[0] = 2
    a.sort.last.should == 2
  end

  it "sorts an array that has a value shifted off with a block" do
    a = @subject.new(Array.new(20, 1))
    a.shift
    a[0] = 2
    a.sort {|x, y| x <=> y }.last.should == 2
  end

  it "raises an error if objects can't be compared" do
    a = @subject.new([CollectionSpecs::Uncomparable.new, CollectionSpecs::Uncomparable.new])
    -> {a.sort}.should raise_error(ArgumentError)
  end

  # From a strange Rubinius bug
  it "handles a large array that has been pruned" do
    pruned = @subject.new(CollectionSpecs::LargeArray.dup.delete_if { |n| n !~ /^test./ })
    pruned.sort.should == CollectionSpecs::LargeTestArraySorted
  end

  # New Interface
  # it "does not return subclass instance on Array subclasses" do
  #   ary = @subject.new(CollectionSpecs::MyArray[1, 2, 3])
  #   ary.sort.should be_an_instance_of(Array)
  # end
end

describe :collection_sort!, shared: true do
  it "sorts array in place using <=>" do
    a = @subject.new([1, -2, 3, 9, 1, 5, -5, 1000, -5, 2, -10, 14, 6, 23, 0])
    a.sort!
    a.should == [-10, -5, -5, -2, 0, 1, 1, 2, 3, 5, 6, 9, 14, 23, 1000]
  end

  it "sorts array in place using block value if a block given" do
    a = @subject.new([0, 15, 2, 3, 4, 6, 14, 5, 7, 12, 8, 9, 1, 10, 11, 13])
    a.sort! { |x, y| y <=> x }.should == (0..15).to_a.reverse
  end

  it "returns self if the order of elements changed" do
    a = @subject.new([6, 7, 2, 3, 7])
    a.sort!.should equal(a)
    a.should == [2, 3, 6, 7, 7]
  end

  it "returns self even if makes no modification" do
    a = @subject.new([1, 2, 3, 4, 5])
    a.sort!.should equal(a)
    a.should == [1, 2, 3, 4, 5]
  end

  it "properly handles recursive arrays" do
    empty = CollectionSpecs.empty_recursive_array(@subject)
    empty.sort!.should == empty

    array = [[]]; array << array
    array.sort!.should == array
  end

  it "uses #<=> of elements in order to sort" do
    a = CollectionSpecs::MockForCompared.new
    b = CollectionSpecs::MockForCompared.new
    c = CollectionSpecs::MockForCompared.new

    CollectionSpecs::MockForCompared.compared?.should == false
    @subject.new([a, b, c]).sort!.should == [c, b, a]
    CollectionSpecs::MockForCompared.compared?.should == true
  end

  # New Interface

  # it "does not call #<=> on contained objects when invoked with a block" do
  #   a = @subject.new(Array.new(25))
  #   (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

  #   a.sort! { -1 }.should be_an_instance_of(Array)
  # end

  # it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
  #   a = @subject.new(Array.new(1500))
  #   (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

  #   a.sort! { -1 }.should be_an_instance_of(Array)
  # end

  # it "completes when supplied a block that always returns the same result" do
  #   a = @subject.new([2, 3, 5, 1, 4])
  #   a.sort!{  1 }.should be_an_instance_of(Array)
  #   a.sort!{  0 }.should be_an_instance_of(Array)
  #   a.sort!{ -1 }.should be_an_instance_of(Array)
  # end

  it "raises a FrozenError on a frozen array" do
    -> { CollectionSpecs.frozen_array(@subject).sort! }.should raise_error(FrozenError)
  end

  it "returns the specified value when it would break in the given block" do
    @subject.new([1, 2, 3]).sort{ break :a }.should == :a
  end

  it "makes some modification even if finished sorting when it would break in the given block" do
    partially_sorted = @subject.new (1..5).map{|i|
      ary = [5, 4, 3, 2, 1]
      ary.sort!{|x,y| break if x==i; x<=>y}
      ary
    }
    partially_sorted.any?{|ary| ary != [1, 2, 3, 4, 5]}.should be_true
  end
end


describe "Array#sort" do
  before { @subject = Array }

  it_behaves_like :collection_sort, :sort

  it "does not call #<=> on contained objects when invoked with a block" do
    a = Array.new(25)
    (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort { -1 }.should be_an_instance_of(Array)
  end

  it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
    a = Array.new(1500)
    (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort { -1 }.should be_an_instance_of(Array)
  end

  it "completes when supplied a block that always returns the same result" do
    a = [2, 3, 5, 1, 4]
    a.sort {  1 }.should be_an_instance_of(Array)
    a.sort {  0 }.should be_an_instance_of(Array)
    a.sort { -1 }.should be_an_instance_of(Array)
  end

  it "does not return subclass instance on Array subclasses" do
    ary = CollectionSpecs::MyArray[1, 2, 3]
    ary.sort.should be_an_instance_of(Array)
  end
end

describe "Collection#sort" do
  before { @subject = Group }

  it_behaves_like :collection_sort, :sort

  it "does not call #<=> on contained objects when invoked with a block" do
    a = Group.new(25)
    (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort { -1 }.should be_an_instance_of(Group)
  end

  it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
    a = Group.new(1500)
    (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort { -1 }.should be_an_instance_of(Group)
  end

  it "completes when supplied a block that always returns the same result" do
    a = Group.new([2, 3, 5, 1, 4])
    a.sort {  1 }.should be_an_instance_of(Group)
    a.sort {  0 }.should be_an_instance_of(Group)
    a.sort { -1 }.should be_an_instance_of(Group)
  end

  it "does not return subclass instance on Array subclasses" do
    ary = Group.new([1, 2, 3])
    ary.sort.should be_an_instance_of(Group)
  end
end

describe "Array#sort!" do
  before { @subject = Array }

  it_behaves_like :collection_sort!, :sort!

  it "completes when supplied a block that always returns the same result" do
    a = @subject.new([2, 3, 5, 1, 4])
    a.sort!{  1 }.should be_an_instance_of(Array)
    a.sort!{  0 }.should be_an_instance_of(Array)
    a.sort!{ -1 }.should be_an_instance_of(Array)
  end

  it "does not call #<=> on contained objects when invoked with a block" do
    a = @subject.new(Array.new(25))
    (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort! { -1 }.should be_an_instance_of(Array)
  end

  it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
    a = @subject.new(Array.new(1500))
    (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort! { -1 }.should be_an_instance_of(Array)
  end
end

describe "Collection#sort!" do
  before { @subject = Group }

  it_behaves_like :collection_sort!, :sort!

  it "completes when supplied a block that always returns the same result" do
    a = @subject.new([2, 3, 5, 1, 4])
    a.sort!{  1 }.should be_an_instance_of(Group)
    a.sort!{  0 }.should be_an_instance_of(Group)
    a.sort!{ -1 }.should be_an_instance_of(Group)
  end

  it "does not call #<=> on contained objects when invoked with a block" do
    a = @subject.new(Array.new(25))
    (0...25).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort! { -1 }.should be_an_instance_of(Group)
  end

  it "does not call #<=> on elements when invoked with a block even if Array is large (Rubinius #412)" do
    a = @subject.new(Array.new(1500))
    (0...1500).each {|i| a[i] = CollectionSpecs::UFOSceptic.new }

    a.sort! { -1 }.should be_an_instance_of(Group)
  end
end
