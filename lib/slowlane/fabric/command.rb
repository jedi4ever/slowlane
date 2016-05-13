require 'thor'
class SlowlaneFabric < Thor

  class_option :username , :default => '<username>' , :required => true, :desc => 'username [SLOWLANE_FABRIC_USERNAME]'
  class_option :password , :default => '<password>' , :required => true, :desc => 'password [SLOWLANE_FABRIC_PASSWORD]'
  class_option :team , :default => '<team>' , :required => false, :desc => 'team [SLOWLANE_FABRIC_TEAM]'

  desc "app SUBCOMMAND ...ARGS", "manage apps"
  subcommand "app", Slowlane::Fabric::App

  desc "organization SUBCOMMAND ...ARGS", "manage organizations"
  subcommand "organization", Slowlane::Fabric::Organization

  desc "tester SUBCOMMAND ...ARGS", "manage testers"
  subcommand "tester", Slowlane::Fabric::Tester

end
