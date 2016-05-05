#require File.expand_path("../lib/slowlane/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "slowlane"
  s.version     = "0.0.1.alpha"
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ["Patrick Debois"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://github.com/jedi4ever/slowlane/"
  s.summary     = %q{Fastlane without the magic - managing ios deployment}
  s.description = %q{Cli version without supprises}

  s.required_rubygems_version = ">= 2.0.6"
  s.rubyforge_project         = "slowlane"
  
  s.add_dependency "thor"
  s.add_dependency "spaceship"
  s.add_dependency "fastlane_core"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'

end
