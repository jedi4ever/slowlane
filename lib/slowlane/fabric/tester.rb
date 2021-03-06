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

      desc "info", "get info of tester <email>"
      def info(email)

        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)

        tester = fabric.find_tester_by_email(email)
        if tester.nil?
          puts "No tester with email #{email} found"
          exit(-1)
        end

        devices = fabric.list_tester_devices(tester['id'])
        groups = fabric.list_tester_groups(tester['id'])
        apps = fabric.list_tester_apps(tester['id'])

        require 'pp'
        pp devices
        pp groups
        pp apps

      end

      desc "resend_invitation", "invite tester with <email> to app with <bundle_id>"
      def resend_invitation(email,bundle_id)
        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)

        apps = fabric.find_apps_by_bundle_id(bundle_id)
        apps.each do |app|
        fabric.tester_resend_invitation(app['id'],email)
        end
      end

      desc "invite", "invite tester with <email> to <bundle_id> in group <group_name>"
      def invite(email,bundle_id,group_name)
        c=Utils.credentials(options)

        fabric = Slowlane::Fabric::Client.new
        fabric.username = c.username
        fabric.password = c.password
        fabric.team = Utils.team(options)

        group = fabric.find_group_by_name(group_name)

        apps = fabric.find_apps_by_bundle_id(bundle_id)
        apps.each do |app|
          fabric.tester_invite(app['id'],group['id'],email)
        end
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

        tester = fabric.find_tester_by_email(email)
        if tester.nil?
          puts "No tester with email #{email} found"
          exit(-1)
        end

        devices = fabric.list_devices(tester['id'])

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
