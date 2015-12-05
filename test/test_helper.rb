require "minitest/autorun"
require "minitest/pride"

require "fog/aws"
require "shrine/storage/fog"

require "forwardable"
require "stringio"

require "dotenv"
Dotenv.load!

class FakeIO
  def initialize(content)
    @io = StringIO.new(content)
  end

  extend Forwardable
  delegate [:read, :size, :close, :eof?, :rewind] => :@io
end

class Minitest::Test
  def fakeio(content = "file")
    FakeIO.new(content)
  end
end
