require 'spaceship'
require_relative './util.rb'

module Slowlane
  module Itunes
    class Team < Thor

      desc "list", "List apps"
      def list()
        require "spaceship"

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        Spaceship::Tunes.client.teams.each do |team|
          require 'pp'
          pp team
          #puts "#{team['teamId']}|#{team['type']}|#{team['name']}"
        end

      end

    end
  end
end
