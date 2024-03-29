describe :array_collect, shared: true do
  it "returns a copy of array with each element replaced by the value returned by block" do
    a = @subject.new(['a', 'b', 'c', 'd'])
    b = a.send(@method) { |i| i + '!' }
    b.should == ["a!", "b!", "c!", "d!"]
    b.should_not equal a
  end

  it "does not return subclass instance" do
    CollectionSpecs::MyArray[1, 2, 3].send(@method) { |x| x + 1 }.should be_an_instance_of(Array)
  end

  it "does not change self" do
    a = @subject.new(['a', 'b', 'c', 'd'])
    a.send(@method) { |i| i + '!' }
    a.should == ['a', 'b', 'c', 'd']
  end

  it "returns the evaluated value of block if it broke in the block" do
    a = @subject.new(['a', 'b', 'c', 'd'])
    b = a.send(@method) {|i|
      if i == 'c'
        break 0
      else
        i + '!'
      end
    }
    b.should == 0
  end

  it "returns an Enumerator when no block given" do
    a = @subject.new([1, 2, 3])
    a.send(@method).should be_an_instance_of(Enumerator)
  end

  it "raises an ArgumentError when no block and with arguments" do
    a = @subject.new([1, 2, 3])
    -> {
      a.send(@method, :foo)
    }.should raise_error(ArgumentError)
  end

  ruby_version_is ''...'2.7' do
    it "does not copy tainted status" do
      a = @subject.new([1, 2, 3])
      a.taint
      a.send(@method){|x| x}.tainted?.should be_false
    end

    it "does not copy untrusted status" do
      a = @subject.new([1, 2, 3])
      a.untrust
      a.send(@method){|x| x}.untrusted?.should be_false
    end
  end
end

describe :array_collect_b, shared: true do
  it "replaces each element with the value returned by block" do
    a = @subject.new([7, 9, 3, 5])
    a.send(@method) { |i| i - 1 }.should equal(a)
    a.should == [6, 8, 2, 4]
  end

  it "returns self" do
    a = @subject.new([1, 2, 3, 4, 5])
    b = a.send(@method) {|i| i+1 }
    a.should equal b
  end

  it "returns the evaluated value of block but its contents is partially modified, if it broke in the block" do
    a = @subject.new(['a', 'b', 'c', 'd'])
    b = a.send(@method) {|i|
      if i == 'c'
        break 0
      else
        i + '!'
      end
    }
    b.should == 0
    a.should == ['a!', 'b!', 'c', 'd']
  end

  it "returns an Enumerator when no block given, and the enumerator can modify the original array" do
    a = @subject.new([1, 2, 3])
    enum = a.send(@method)
    enum.should be_an_instance_of(Enumerator)
    enum.each{|i| "#{i}!" }
    a.should == ["1!", "2!", "3!"]
  end

  ruby_version_is ''...'2.7' do
    it "keeps tainted status" do
      a = @subject.new([1, 2, 3])
      a.taint
      a.tainted?.should be_true
      a.send(@method){|x| x}
      a.tainted?.should be_true
    end

    it "keeps untrusted status" do
      a = @subject.new([1, 2, 3])
      a.untrust
      a.send(@method){|x| x}
      a.untrusted?.should be_true
    end
  end

  describe "when frozen" do
    it "raises a FrozenError" do
      -> { CollectionSpecs.frozen_array(@subject).send(@method) {} }.should raise_error(FrozenError)
    end

    it "raises a FrozenError when empty" do
      -> { CollectionSpecs.empty_frozen_array(@subject).send(@method) {} }.should raise_error(FrozenError)
    end

    it "raises a FrozenError when calling #each on the returned Enumerator" do
      enumerator = CollectionSpecs.frozen_array(@subject).send(@method)
      -> { enumerator.each {|x| x } }.should raise_error(FrozenError)
    end

    it "raises a FrozenError when calling #each on the returned Enumerator when empty" do
      enumerator = CollectionSpecs.empty_frozen_array(@subject).send(@method)
      -> { enumerator.each {|x| x } }.should raise_error(FrozenError)
    end
  end
end
