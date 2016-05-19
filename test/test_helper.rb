require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"

require "fog/aws"
require "shrine/storage/fog"

require "forwardable"
require "stringio"

require "dotenv"
Dotenv.load!
