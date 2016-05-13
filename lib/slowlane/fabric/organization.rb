require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class Organization <Thor

      desc "list", "get list of organizations"
      def list

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        orgs = fabric.list_organizations

        puts orgs
        headings = ['id', 'name', 'alias','accounts_count', 'build_secret', 'api_key']
        rows = []

        orgs.each do |org|
          row = []
          row << org['id']
          row << org['name']
          row << org['alias']
          row << org['accounts_count']
          row << org['build_secret']
          row << org['api_key']
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
