#require File.expand_path("../lib/slowlane/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "slowlane"
  s.version     = "1.2.3"
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ["Patrick Debois"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://github.com/jedi4ever/slowlane/"
  s.summary     = %q{Fastlane without the magic}
  s.description = %q{Fastlane Cli without supprises}

  s.required_rubygems_version = ">= 2.0.6"
  s.rubyforge_project         = "slowlane"
  
  s.add_dependency "thor"
  s.add_dependency "spaceship"
  s.add_dependency "fastlane_core", '~> 0.43.1'
  s.add_dependency "terminal-table", '~> 1.4'
  s.add_dependency 'rubyzip', '~> 1.1'
  s.add_dependency 'zip-zip'
  s.add_dependency 'mechanize'
  s.add_dependency 'CFPropertyList'
  #s.add_dependency 'openssl'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'

end
