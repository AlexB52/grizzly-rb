require_relative '../../../spec_helper'
require_relative 'fixtures/classes'

describe :collection_at, shared: true do
  it "returns the (n+1)'th element for the passed index n" do
    a = @subject.new [1, 2, 3, 4, 5, 6]
    a.at(0).should == 1
    a.at(1).should == 2
    a.at(5).should == 6
  end

  it "returns nil if the given index is greater than or equal to the array's length" do
    a = @subject.new [1, 2, 3, 4, 5, 6]
    a.at(6).should == nil
    a.at(7).should == nil
  end

  it "returns the (-n)'th element from the last, for the given negative index n" do
    a = @subject.new  [1, 2, 3, 4, 5, 6]
    a.at(-1).should == 6
    a.at(-2).should == 5
    a.at(-6).should == 1
  end

  it "returns nil if the given index is less than -len, where len is length of the array"  do
    a = @subject.new  [1, 2, 3, 4, 5, 6]
    a.at(-7).should == nil
    a.at(-8).should == nil
  end

  it "does not extend the array unless the given index is out of range" do
    a = @subject.new  [1, 2, 3, 4, 5, 6]
    a.length.should == 6
    a.at(100)
    a.length.should == 6
    a.at(-100)
    a.length.should == 6
  end

  it "tries to convert the passed argument to an Integer using #to_int" do
    a = @subject.new  ["a", "b", "c"]
    a.at(0.5).should == "a"

    obj = mock('to_int')
    obj.should_receive(:to_int).and_return(2)
    a.at(obj).should == "c"
  end

  it "raises a TypeError when the passed argument can't be coerced to Integer" do
    -> { @subject.new ([]).at("cat") }.should raise_error(TypeError)
  end

  it "raises an ArgumentError when 2 or more arguments are passed" do
    -> { @subject.new ([:a, :b]).at(0,1) }.should raise_error(ArgumentError)
  end
end

describe "Array#at" do
  before { @subject = Array }

  it_behaves_like :collection_at, :at
end

describe "Collection#at" do
  before { @subject = Group }

  it_behaves_like :collection_at, :at
end