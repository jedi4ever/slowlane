require_relative './util.rb'
require 'terminal-table'
require "spaceship"

module Slowlane
  module Portal
    class App < Thor

      desc "list", "List apps"
      class_option :team , :default => '<team>' , :required => true
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        headings = ['appId', 'platform', 'prefix', 'wildcard', 'bundle_id', 'name']
        rows = []
        Spaceship::Portal.app.all.find_all do |app|
          row=[]
          row << app.app_id
          row << app.platform
          row << app.prefix
          row << app.is_wildcard
          row << app.bundle_id
          row << app.name
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table


      end

    end
  end
end
