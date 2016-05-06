require_relative './util.rb'
require "spaceship"
require 'terminal-table'


module Slowlane
  module Portal
    class Profile < Thor

      desc "add_device","add_device <bundle_id> <device>"
      def add_device(bundle_id,device)
        puts bundle_id
        puts device
      end

      desc "list", "List profiles"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        rows = []
        headings = [ 'uuid', 'id', 'distribution_method', 'name' ]
        Spaceship::Portal.provisioning_profile.all.find_all do |profile|
          row = []
          row << profile.uuid
          row << profile.id
          row << profile.distribution_method
          row << profile.name
          unless options[:filter].nil?
            if profile.name =~ /#{options[:filter]}/
              rows << row
            end
          else
            rows << row
          end

        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end
    end
  end
end
