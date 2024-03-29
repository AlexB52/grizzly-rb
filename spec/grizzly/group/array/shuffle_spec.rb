require_relative '../../../spec_helper'
require_relative 'fixtures/classes'

describe :collection_shuffle, shared: true do
  it "returns the same values, in a usually different order" do
    a = @subject.new([1, 2, 3, 4])
    different = false
    10.times do
      s = a.shuffle
      s.sort.should == a
      different ||= (a != s)
    end
    different.should be_true # Will fail once in a blue moon (4!^10)
  end

  it "is not destructive" do
    a = @subject.new([1, 2, 3])
    10.times do
      a.shuffle
      a.should == [1, 2, 3]
    end
  end

  # New Interface

  # it "does not return subclass instances with Array subclass" do
  #   CollectionSpecs::MyArray[1, 2, 3].shuffle.should be_an_instance_of(Array)
  # end

  it "calls #rand on the Object passed by the :random key in the arguments Hash" do
    obj = mock("array_shuffle_random")
    obj.should_receive(:rand).at_least(1).times.and_return(0.5)

    result = @subject.new([1, 2]).shuffle(random: obj)
    result.size.should == 2
    result.should include(1, 2)
  end

  it "raises a NoMethodError if an object passed for the RNG does not define #rand" do
    obj = BasicObject.new

    -> { @subject.new([1, 2]).shuffle(random: obj) }.should raise_error(NoMethodError)
  end

  # New Interface

  # it "accepts a Float for the value returned by #rand" do
  #   random = mock("array_shuffle_random")
  #   random.should_receive(:rand).at_least(1).times.and_return(0.3)

  #   @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Array)
  # end

  # it "calls #to_int on the Object returned by #rand" do
  #   value = mock("array_shuffle_random_value")
  #   value.should_receive(:to_int).at_least(1).times.and_return(0)
  #   random = mock("array_shuffle_random")
  #   random.should_receive(:rand).at_least(1).times.and_return(value)

  #   @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Array)
  # end

  it "raises a RangeError if the value is less than zero" do
    value = mock("array_shuffle_random_value")
    value.should_receive(:to_int).and_return(-1)
    random = mock("array_shuffle_random")
    random.should_receive(:rand).and_return(value)

    -> { @subject.new([1, 2]).shuffle(random: random) }.should raise_error(RangeError)
  end

  it "raises a RangeError if the value is equal to one" do
    value = mock("array_shuffle_random_value")
    value.should_receive(:to_int).at_least(1).times.and_return(1)
    random = mock("array_shuffle_random")
    random.should_receive(:rand).at_least(1).times.and_return(value)

    -> { @subject.new([1, 2]).shuffle(random: random) }.should raise_error(RangeError)
  end
end

describe :collection_shuffle!, shared: true do
  it "returns the same values, in a usually different order" do
    a = @subject.new([1, 2, 3, 4])
    original = a
    different = false
    10.times do
      a = a.shuffle!
      a.sort.should == [1, 2, 3, 4]
      different ||= (a != [1, 2, 3, 4])
    end
    different.should be_true # Will fail once in a blue moon (4!^10)
    a.should equal(original)
  end

  it "raises a FrozenError on a frozen array" do
    -> { CollectionSpecs.frozen_array(@subject).shuffle! }.should raise_error(FrozenError)
    -> { CollectionSpecs.empty_frozen_array(@subject).shuffle! }.should raise_error(FrozenError)
  end
end

describe "Array#shuffle" do
  before { @subject = Array }

  it_behaves_like :collection_shuffle, :shuffle
  it_behaves_like :collection_shuffle!, :shuffle!

  it "does not return subclass instances with Array subclass" do
    CollectionSpecs::MyArray[1, 2, 3].shuffle.should be_an_instance_of(Array)
  end

  it "accepts a Float for the value returned by #rand" do
    random = mock("array_shuffle_random")
    random.should_receive(:rand).at_least(1).times.and_return(0.3)

    @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Array)
  end

  it "calls #to_int on the Object returned by #rand" do
    value = mock("array_shuffle_random_value")
    value.should_receive(:to_int).at_least(1).times.and_return(0)
    random = mock("array_shuffle_random")
    random.should_receive(:rand).at_least(1).times.and_return(value)

    @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Array)
  end
end

describe "Collection#shuffle" do
  before { @subject = Group }

  it_behaves_like :collection_shuffle, :shuffle
  it_behaves_like :collection_shuffle!, :shuffle!

  it "does not return subclass instances with Array subclass" do
    Group.new([1, 2, 3]).shuffle.should be_an_instance_of(Group)
  end

  it "accepts a Float for the value returned by #rand" do
    random = mock("array_shuffle_random")
    random.should_receive(:rand).at_least(1).times.and_return(0.3)

    @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Group)
  end

  it "calls #to_int on the Object returned by #rand" do
    value = mock("array_shuffle_random_value")
    value.should_receive(:to_int).at_least(1).times.and_return(0)
    random = mock("array_shuffle_random")
    random.should_receive(:rand).at_least(1).times.and_return(value)

    @subject.new([1, 2]).shuffle(random: random).should be_an_instance_of(Group)
  end
end
