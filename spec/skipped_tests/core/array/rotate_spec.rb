require_relative '../../spec_helper'

describe "Array#rotate" do
  # core/array/rotate_spec.rb:63
  it "returns subclass instance for Array subclasses" do
    MyCollection[1, 2, 3].rotate.should be_an_instance_of(MyCollection)
  end
end
