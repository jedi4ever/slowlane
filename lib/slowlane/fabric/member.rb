require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class Member <Thor

      desc "list", "get list of members"
      def list

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        members = fabric.list_members

        headings = ['id', 'name', 'email','phone', 'is_admin', 'is_activated']
        rows = []

        members.each do |org|
          row = []
          row << org['id']
          row << org['name']
          row << org['email']
          row << org['phone']
          row << org['is_admin']
          row << org['is_activated']
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
