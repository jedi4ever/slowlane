require 'spaceship'
require_relative './util.rb'
require 'terminal-table'

module Slowlane
  module Itunes
    class Team < Thor

      desc "list", "List apps"
      def list()
        require "spaceship"

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        headings = ['vendorId', 'name', 'type', 'roles', 'lastlogin']
        rows = []
        Spaceship::Tunes.client.teams.each do |team|
          provider = team['contentProvider']
          row = []
          row << provider['contentProviderId']
          row << provider['name']
          row << provider['contentProviderTypes'].join(',')
          row << team['roles'].join(',')
          row << Time.at(team['lastLogin']/1000) .to_datetime
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

    end
  end
end
