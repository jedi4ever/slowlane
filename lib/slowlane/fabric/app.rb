require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class App <Thor

      desc "apps", "get list of apps"
      def list

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        apps = fabric.list_apps()

        headings = ['id', 'name', 'bundle_id', 'plaform', 'status']
        rows = []

        require 'pp'
        pp apps
        apps.each do |app|
          row = []
          row << app['id']
          row << app['name']
          row << app['bundle_identifier']
          row << app['platform']
          row << app['status']
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
