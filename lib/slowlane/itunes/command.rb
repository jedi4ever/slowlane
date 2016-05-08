require 'thor'
class SlowlaneItunes < Thor

  class_option :username , :default => '<username>' , :required => true, :desc => 'username [SLOWLANE_ITUNES_USERNAME]'
  class_option :password , :default => '<password>' , :required => true, :desc => 'password [SLOWLANE_ITUNES_PASSWORD]'
  class_option :team , :default => '<team>' , :required => false, :desc => 'team [SLOWLANE_ITUNES_TEAM]'

  desc "app SUBCOMMAND ...ARGS", "manage apps"
  subcommand "app", Slowlane::Itunes::App

  desc "team SUBCOMMAND ...ARGS", "manage teams"
  subcommand "team", Slowlane::Itunes::Team

  desc "build SUBCOMMAND ...ARGS", "manage builds"
  subcommand "build", Slowlane::Itunes::Build

  desc "tester SUBCOMMAND ...ARGS", "manage testers"
  subcommand "tester", Slowlane::Itunes::Tester

  desc "autocomplete","provide autocompletion",:hide => true
  def autocomplete
    class_options = self.class.class_options
    commands = self.class.commands
    commands.each do |command_name,command|
      unless command.instance_of? Thor::HiddenCommand
        subcommand_class = Object.const_get("Slowlane::Itunes::"+command_name.capitalize)
        subcommand_class.commands.each do |subcommand_name,subcommand|
          available_options = []
          options = subcommand.options
          options.each do |option_name,option|
            available_options << "--#{option_name}"
          end
          class_options.each do |option_name,option|
            available_options << "--#{option_name}"
          end
          puts "#{command_name}::#{subcommand_name} : #{available_options.join(',')}"
        end
      end
    end

  end

end
