require_relative './util.rb'
require "spaceship"

module Slowlane
  module Itunes
    class App < Thor

      desc "list", "List apps"
      class_option :team , :default => '<team>' , :required => true
      def list()

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t
        

        Spaceship::Tunes::Application.all.collect do |app|
          require 'pp' 
          pp app
          #pp app.details
          #pp app.live_version
          pp app.edit_version
          pp app.edit_version.candidate_builds unless app.edit_version.nil?
        end

      end

    end

  end
end
