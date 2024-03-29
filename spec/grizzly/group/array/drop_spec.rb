require_relative '../../../spec_helper'


describe :collection_drop, shared: true do
  it "removes the specified number of elements from the start of the array" do
    @subject.new([1, 2, 3, 4, 5]).drop(2).should == [3, 4, 5]
  end

  it "raises an ArgumentError if the number of elements specified is negative" do
   -> { @subject.new([1, 2]).drop(-3) }.should raise_error(ArgumentError)
  end

  it "returns an empty Array if all elements are dropped" do
    @subject.new([1, 2]).drop(2).should == []
  end

  it "returns an empty Array when called on an empty Array" do
    @subject.new([]).drop(0).should == []
  end

  it "does not remove any elements when passed zero" do
    @subject.new([1, 2]).drop(0).should == [1, 2]
  end

  it "returns an empty Array if more elements than exist are dropped" do
    @subject.new([1, 2]).drop(3).should == []
  end

  it 'acts correctly after a shift' do
    ary = @subject.new([nil, 1, 2])
    ary.shift
    ary.drop(1).should == [2]
  end

  it "tries to convert the passed argument to an Integer using #to_int" do
    obj = mock("to_int")
    obj.should_receive(:to_int).and_return(2)

    @subject.new([1, 2, 3]).drop(obj).should == [3]
  end

  it "raises a TypeError when the passed argument can't be coerced to Integer" do
    -> { @subject.new([1, 2]).drop("cat") }.should raise_error(TypeError)
  end

  it "raises a TypeError when the passed argument isn't an integer and #to_int returns non-Integer" do
    obj = mock("to_int")
    obj.should_receive(:to_int).and_return("cat")

    -> { @subject.new([1, 2]).drop(obj) }.should raise_error(TypeError)
  end
end

describe "Array#drop" do
  before { @subject = Array }

  it_behaves_like :collection_drop, :drop

  it 'returns an instance of a subclass' do
    @subject.new([1,2,3,4,5]).drop(1).should be_an_instance_of(@subject)
  end
end

describe "Collection#drop" do
  before { @subject = Group }

  it_behaves_like :collection_drop, :drop

  it 'returns an instance of a subclass' do
    @subject.new([1,2,3,4,5]).drop(1).should be_an_instance_of(@subject)
  end
end
