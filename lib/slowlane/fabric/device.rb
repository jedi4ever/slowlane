require_relative './util.rb'
require_relative './client.rb'
require 'terminal-table'

module Slowlane
  module Fabric 
    class Device <Thor

      desc "list", "get list of devices"
      def list

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

        all_devices = []

        testers = fabric.list_testers(nil)
        testers.each do |tester|
          tester_id = tester['id']
          if tester_id.is_a? Integer
            tester_devices = fabric.list_devices(app['id'],tester_id)
            tester_devices.each do |d|
              d['owner'] = tester['name']
              d['email'] = tester['email']
              all_devices << d
            end
          end

        end

        headings = ['owner','email','id', 'name', 'platform', 'type' , 'os_version', 'transferred']
        rows = []

        all_devices.each do |device|
          row = []

          row << device['owner']
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
