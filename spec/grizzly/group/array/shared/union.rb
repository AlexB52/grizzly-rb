describe :array_binary_union, shared: true do
  it "returns an array of elements that appear in either array (union)" do
    @subject.new([]).send(@method, []).should == []
    @subject.new([1, 2]).send(@method, []).should == [1, 2]
    @subject.new([]).send(@method, [1, 2]).should == [1, 2]
    @subject.new([ 1, 2, 3, 4 ]).send(@method, [ 3, 4, 5 ]).should == [1, 2, 3, 4, 5]
  end

  it "creates an array with no duplicates" do
    @subject.new([ 1, 2, 3, 1, 4, 5 ]).send(@method, [ 1, 3, 4, 5, 3, 6 ]).should == [1, 2, 3, 4, 5, 6]
  end

  it "creates an array with elements in order they are first encountered" do
    @subject.new([ 1, 2, 3, 1 ]).send(@method, [ 1, 3, 4, 5 ]).should == [1, 2, 3, 4, 5]
  end

  it "properly handles recursive arrays" do
    empty = CollectionSpecs.empty_recursive_array(@subject)
    empty.send(@method, empty).should == empty

    array = CollectionSpecs.recursive_array(@subject)
    array.send(@method, []).should == [1, 'two', 3.0, array]
    @subject.new([]).send(@method, array).should == [1, 'two', 3.0, array]
    array.send(@method, array).should == [1, 'two', 3.0, array]
    array.send(@method, empty).should == [1, 'two', 3.0, array, empty]
  end

  it "tries to convert the passed argument to an Array using #to_ary" do
    obj = mock('[1,2,3]')
    obj.should_receive(:to_ary).and_return([1, 2, 3])
    @subject.new([0]).send(@method, obj).should == ([0] | [1, 2, 3])
  end

  # MRI follows hashing semantics here, so doesn't actually call eql?/hash for Fixnum/Symbol
  it "acts as if using an intermediate hash to collect values" do
    not_supported_on :opal do
      @subject.new([5.0, 4.0]).send(@method, [5, 4]).should == [5.0, 4.0, 5, 4]
    end

    str = "x"
    @subject.new([str]).send(@method, [str.dup]).should == [str]

    obj1 = mock('1')
    obj2 = mock('2')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj2.should_receive(:eql?).at_least(1).and_return(true)

    @subject.new([obj1]).send(@method, [obj2]).should == [obj1]
    @subject.new([obj1, obj1, obj2, obj2]).send(@method, [obj2]).should == [obj1]

    obj1 = mock('3')
    obj2 = mock('4')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj2.should_receive(:eql?).at_least(1).and_return(false)

    @subject.new([obj1]).send(@method, [obj2]).should == [obj1, obj2]
    @subject.new([obj1, obj1, obj2, obj2]).send(@method, [obj2]).should == [obj1, obj2]
  end

  it "does not call to_ary on array subclasses" do
    @subject.new([1, 2]).send(@method, CollectionSpecs::ToAryArray[5, 6]).should == [1, 2, 5, 6]
  end

  it "properly handles an identical item even when its #eql? isn't reflexive" do
    x = mock('x')
    x.stub!(:hash).and_return(42)
    x.stub!(:eql?).and_return(false) # Stubbed for clarity and latitude in implementation; not actually sent by MRI.

    @subject.new([x]).send(@method, [x]).should == [x]
  end
end
