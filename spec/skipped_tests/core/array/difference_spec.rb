require_relative '../../spec_helper'

describe "Array#difference" do
  # core/array/difference_spec.rb:14
  it "returns subclass instances for Array subclasses" do
    MyGroup[1, 2, 3].difference.should be_an_instance_of(MyGroup)
  end
end
