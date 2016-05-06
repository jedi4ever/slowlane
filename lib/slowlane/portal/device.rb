require_relative './util.rb'
require "spaceship"
require 'terminal-table'

module Slowlane
  module Portal
    class Device < Thor

      desc "list", "List devices"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        headings = [ 'id', 'udid', 'description' ,'status', 'platform', 'model', 'device_type']
        rows = []
        Spaceship::Portal.device.all.find_all do |device|
          row = []
          row << device.id
          row << device.udid
          row << device.name
          row << device.status
          row << device.platform
          row << device.model
          row << device.device_type
          rows << row
        end

         table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

      desc "add", "Add a device <udid> <description>"
      def add(udid, description)

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        newdevice = Spaceship::Portal.device.create!(name: "#{description}", udid: "#{udid}")
        require 'pp'
        pp newdevice

      end
    end
  end
end
