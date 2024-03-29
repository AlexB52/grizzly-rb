require_relative "../../lib/grizzly"

# Running directly with ruby some_spec.rb
unless ENV['MSPEC_RUNNER']
  mspec_lib = File.expand_path("../../mspec/lib", __FILE__)
  $LOAD_PATH << mspec_lib if File.directory?(mspec_lib)

  begin
    require 'mspec'
    require 'mspec/commands/mspec-run'
  rescue LoadError
    puts "Please add -Ipath/to/mspec/lib or clone mspec as a sibling to run the specs."
    exit 1
  end

  ARGV.unshift $0
  MSpecRun.main
end

# Fixtures Array

class MyCollection < Grizzly::Collection; end

# Fixtures Enumerable

class Numerous
  include Grizzly::Enumerable
  attr_accessor :list
  def initialize(list = [2, 5, 3, 6, 1, 4])
    @list = list
  end

  def each
    @list.each { |i| yield i }
  end

  def ==(other)
    list == other.list
  end
end

class EachCounter < Numerous
  attr_reader :times_called, :times_yielded, :arguments_passed
  def initialize(list)
    super(list)
    @times_yielded = @times_called = 0
  end

  def each(*arg)
    @times_called += 1
    @times_yielded = 0
    @arguments_passed = arg
    @list.each do |i|
      @times_yielded +=1
      yield i
    end
  end

  def ==(other)
    list == other.list
  end
end

class ThrowingEach
  include Grizzly::Enumerable
  attr_accessor :list
  def initialize(list = [])
    @list = list
  end

  def each
    raise "from each"
  end

  def ==(other)
    list == other.list
  end
end

class YieldsMulti
  include Grizzly::Enumerable

  attr_accessor :list
  def initialize(list = (1..9).to_a)
    @list = list
  end

  def ==(other)
    list == other.list
  end

  def each
    i = 2
    list = @list.dup
    until list.empty?
      yield *list.shift(i)
      i += 1
    end
  end
end

class MapReturnsEnumerable
  include Grizzly::Enumerable
  attr_accessor :list
  def initialize(list = (1..9).to_a)
    @list = list
  end

  def ==(other)
    list == other.list
  end

  class EnumerableMapping
    include Grizzly::Enumerable

    def initialize(items, block)
      @items = items
      @block = block
    end

    def each
      @items.each do |i|
        yield @block.call(i)
      end
    end
  end

  def each
    yield 1
    yield 2
    yield 3
  end

  def map(&block)
    EnumerableMapping.new(self, block)
  end
end

class ReverseComparable
  include Comparable
  def initialize(num)
    @num = num
  end

  attr_accessor :num

  # Reverse comparison
  def <=>(other)
    other.num <=> @num
  end
end

class Freezy
  include Grizzly::Enumerable

  attr_accessor :list
  def initialize(list = [])
    @list = list
  end

  def ==(other)
    list == other.list
  end

  def each
    yield 1
    yield 2
  end

  def to_a
    super.freeze
  end
end

class ComparesByVowelCount

  attr_accessor :value, :vowels

  def self.wrap(*args)
    args.map {|element| ComparesByVowelCount.new(element)}
  end

  def initialize(string)
    self.value = string
    self.vowels = string.gsub(/[^aeiou]/, '').size
  end

  def <=>(other)
    self.vowels <=> other.vowels
  end

end

class ComparableWithInteger
  include Comparable
  def initialize(num)
    @num = num
  end

  def <=>(fixnum)
    @num <=> fixnum
  end
end
