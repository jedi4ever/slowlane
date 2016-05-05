require_relative './util.rb'
require "spaceship"

module Slowlane
  module Portal
    class Device < Thor

      desc "list", "List devices"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        Spaceship::Portal.device.all.find_all do |device|
          puts "#{device.id}|#{device.udid}|#{device.name}"
        end

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
