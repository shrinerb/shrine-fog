Gem::Specification.new do |gem|
  gem.name         = "shrine-fog"
  gem.version      = "2.0.0"

  gem.required_ruby_version = ">= 2.1"

  gem.summary      = "Provides Fog storage for Shrine."
  gem.description  = "Provides Fog storage for Shrine."
  gem.homepage     = "https://github.com/shrinerb/shrine-fog"
  gem.authors      = ["Janko Marohnić"]
  gem.email        = ["janko.marohnic@gmail.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "*.gemspec"]
  gem.require_path = "lib"

  gem.add_dependency "shrine", ">= 3.0.0.rc", "< 4"
  gem.add_dependency "down", "~> 5.0"
  gem.add_dependency "http", ">= 3.2", "< 5"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "fog-aws"
  gem.add_development_dependency "mime-types"
  gem.add_development_dependency "dotenv"
  gem.add_development_dependency "minitest", "~> 5.8"
end
