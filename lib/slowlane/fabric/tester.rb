require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class Tester <Thor

      desc "list", "get list of tester"
      def list(bundle_id)

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        app = fabric.find_app_by_bundle_id(bundle_id)
        app_id = app['id']
        testers = fabric.list_testers(app_id)

        headings = ['id', 'name', 'email','groups' ]
        rows = []

        testers.each do |tester|
          row = []
          row << tester['id']
          row << tester['name']
          row << tester['email']
          groups = tester['groups']
          if groups.nil?
            row << ""
          else
            row << groups.map { |g| g['name'] }.join(",")
          end
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
