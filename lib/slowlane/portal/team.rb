require_relative './util.rb'

module Slowlane
  module Portal
    class Team < Thor

      desc "list", "List apps"
      def list()
        require "spaceship"

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        Spaceship::Portal.client.teams.each do |team|
          puts "#{team['teamId']}|#{team['type']}|#{team['name']}"
        end

      end

    end
  end
end
