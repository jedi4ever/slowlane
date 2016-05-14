require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class Tester <Thor

      desc "list", "get list of tester"
      def list

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        
        testers = fabric.list_testers(nil)

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

      desc "devices", "get devices of tester <email>"
      def devices(email)

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)
        
        apps = fabric.list_apps()
        if apps.nil?
          puts "No applications found"
          exit(-1)
        end

        app = apps.first()
        tester = fabric.find_tester_by_email(email)
        if tester.nil?
          puts "No tester with email #{email} found"
          exit(-1)
        end

        devices = fabric.list_devices(app['id'],tester['id'])

        headings = ['id', 'name', 'platform', 'type' , 'os_version', 'transferred']
        rows = []

        devices.each do |device|
          row = []

          row << device['identifier']
          row << device['model_name']
          row << device['platform']
          row << device['ui_idiom']
          row << device['current_os_version']
          row << device['transferred']

          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
