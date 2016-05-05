require_relative './util.rb'
require "spaceship"

module Slowlane
  module Itunes
    class Build < Thor

      desc "list", "List builds for a particular app <id>"
      class_option :team , :default => '<team>' , :required => true
      class_option :type , :required => true
      def list(id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(id)
        require 'pp' 
        if (options[:type] == 'live') 
          pp app.live_version
        end

        if (options[:type] == 'edit') 
          pp app.edit_version
          pp app.edit_version.candidate_builds unless app.edit_version.nil?
        end

      end


      desc "trains", "List trains for a particular app <id>"
      class_option :team , :default => '<team>' , :required => true
      class_option :type , :required => true
      def trains(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(bundle_id)
        require 'pp'
        pp app.build_trains

      end

      desc "trainnumbers", "List trainnumbers for a particular app <id>,train <train>"
      class_option :team , :default => '<team>' , :required => true
      class_option :type , :required => true
      def trainnumbers(id,train_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(id)
        builds = app.all_builds_for_train(train_id)
        builds.each do |build|
          puts "#{build.train_version}|#{build.build_version}|#{build.app_name}|#{build.platform}|#{build.upload_date}|#{build.processing}|#{build.valid}"
        end

      end

    end

  end
end
