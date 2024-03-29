require_relative '../fixtures/classes'
require_relative '../fixtures/encoded_strings'

describe :array_join_with_default_separator, shared: true do
  before :each do
    @separator = $,
  end

  after :each do
    $, = @separator
  end

  it "returns an empty string if the Array is empty" do
    @subject.new([]).send(@method).should == ''
  end

  it "returns a US-ASCII string for an empty Array" do
    @subject.new([]).send(@method).encoding.should == Encoding::US_ASCII
  end

  it "returns a string formed by concatenating each String element separated by $," do
    suppress_warning {
      $, = " | "
      @subject.new(["1", "2", "3"]).send(@method).should == "1 | 2 | 3"
    }
  end

  it "attempts coercion via #to_str first" do
    obj = mock('foo')
    obj.should_receive(:to_str).any_number_of_times.and_return("foo")
    @subject.new([obj]).send(@method).should == "foo"
  end

  it "attempts coercion via #to_ary second" do
    obj = mock('foo')
    obj.should_receive(:to_str).any_number_of_times.and_return(nil)
    obj.should_receive(:to_ary).any_number_of_times.and_return(["foo"])
    @subject.new([obj]).send(@method).should == "foo"
  end

  it "attempts coercion via #to_s third" do
    obj = mock('foo')
    obj.should_receive(:to_str).any_number_of_times.and_return(nil)
    obj.should_receive(:to_ary).any_number_of_times.and_return(nil)
    obj.should_receive(:to_s).any_number_of_times.and_return("foo")
    @subject.new([obj]).send(@method).should == "foo"
  end

  it "raises a NoMethodError if an element does not respond to #to_str, #to_ary, or #to_s" do
    obj = mock('o')
    class << obj; undef :to_s; end
    -> { @subject.new([1, obj]).send(@method) }.should raise_error(NoMethodError)
  end

  it "raises an ArgumentError when the Array is recursive" do
    -> { CollectionSpecs.recursive_array(@subject).send(@method) }.should raise_error(ArgumentError)
    -> { CollectionSpecs.head_recursive_array(@subject).send(@method) }.should raise_error(ArgumentError)
    -> { CollectionSpecs.empty_recursive_array(@subject).send(@method) }.should raise_error(ArgumentError)
  end

  ruby_version_is ''...'2.7' do
    it "taints the result if the Array is tainted and non-empty" do
      @subject.new([1, 2]).taint.send(@method).tainted?.should be_true
    end

    it "does not taint the result if the Array is tainted but empty" do
      @subject.new([]).taint.send(@method).tainted?.should be_false
    end

    it "taints the result if the result of coercing an element is tainted" do
      s = mock("taint")
      s.should_receive(:to_s).and_return("str".taint)
      @subject.new([s]).send(@method).tainted?.should be_true
    end

    it "untrusts the result if the Array is untrusted and non-empty" do
      @subject.new([1, 2]).untrust.send(@method).untrusted?.should be_true
    end

    it "does not untrust the result if the Array is untrusted but empty" do
      @subject.new([]).untrust.send(@method).untrusted?.should be_false
    end

    it "untrusts the result if the result of coercing an element is untrusted" do
      s = mock("untrust")
      s.should_receive(:to_s).and_return("str".untrust)
      @subject.new([s]).send(@method).untrusted?.should be_true
    end
  end

  it "uses the first encoding when other strings are compatible" do
    ary1 = CollectionSpecs.array_with_7bit_utf8_and_usascii_strings(@subject)
    ary2 = CollectionSpecs.array_with_usascii_and_7bit_utf8_strings(@subject)
    ary3 = CollectionSpecs.array_with_utf8_and_7bit_binary_strings(@subject)
    ary4 = CollectionSpecs.array_with_usascii_and_7bit_binary_strings(@subject)

    @subject.new(ary1).send(@method).encoding.should == Encoding::UTF_8
    @subject.new(ary2).send(@method).encoding.should == Encoding::US_ASCII
    @subject.new(ary3).send(@method).encoding.should == Encoding::UTF_8
    @subject.new(ary4).send(@method).encoding.should == Encoding::US_ASCII
  end

  it "uses the widest common encoding when other strings are incompatible" do
    ary1 = CollectionSpecs.array_with_utf8_and_usascii_strings(@subject)
    ary2 = CollectionSpecs.array_with_usascii_and_utf8_strings(@subject)

    @subject.new(ary1).send(@method).encoding.should == Encoding::UTF_8
    @subject.new(ary2).send(@method).encoding.should == Encoding::UTF_8
  end

  it "fails for arrays with incompatibly-encoded strings" do
    ary_utf8_bad_binary = CollectionSpecs.array_with_utf8_and_binary_strings(@subject)

    -> { ary_utf8_bad_binary.send(@method) }.should raise_error(EncodingError)
  end

  ruby_version_is "2.7" do
    context "when $, is not nil" do
      before do
        suppress_warning do
          $, = '*'
        end
      end

      it "warns" do
        -> { [].join }.should complain(/warning: \$, is set to non-nil value/)
      end
    end
  end
end

describe :array_join_with_string_separator, shared: true do
  it "returns a string formed by concatenating each element.to_str separated by separator" do
    obj = mock('foo')
    obj.should_receive(:to_str).and_return("foo")
    @subject.new([1, 2, 3, 4, obj]).send(@method, ' | ').should == '1 | 2 | 3 | 4 | foo'
  end

  it "uses the same separator with nested arrays" do
    @subject.new([1, [2, [3, 4], 5], 6]).send(@method, ":").should == "1:2:3:4:5:6"
    @subject.new([1, [2, CollectionSpecs::MyArray[3, 4], 5], 6]).send(@method, ":").should == "1:2:3:4:5:6"
  end

  ruby_version_is ''...'2.7' do
    describe "with a tainted separator" do
      before :each do
        @sep = ":".taint
      end

      it "does not taint the result if the array is empty" do
        @subject.new([]).send(@method, @sep).tainted?.should be_false
      end

      it "does not taint the result if the array has only one element" do
        @subject.new([1]).send(@method, @sep).tainted?.should be_false
      end

      it "taints the result if the array has two or more elements" do
        @subject.new([1, 2]).send(@method, @sep).tainted?.should be_true
      end
    end

    describe "with an untrusted separator" do
      before :each do
        @sep = ":".untrust
      end

      it "does not untrust the result if the array is empty" do
        @subject.new([]).send(@method, @sep).untrusted?.should be_false
      end

      it "does not untrust the result if the array has only one element" do
        @subject.new([1]).send(@method, @sep).untrusted?.should be_false
      end

      it "untrusts the result if the array has two or more elements" do
        @subject.new([1, 2]).send(@method, @sep).untrusted?.should be_true
      end
    end
  end
end
