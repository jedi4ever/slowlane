require_relative './util.rb'
require "spaceship"


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

        Spaceship::Portal.provisioning_profile.all.find_all do |profile|
          unless options[:filter].nil?
            if profile.name =~ /#{options[:filter]}/
              puts "#{profile.uuid}|#{profile.id}|#{profile.distribution_method}|#{profile.name}"
            end
          else
            puts "#{profile.uuid}|#{profile.id}|#{profile.distribution_method}|#{profile.name}"
          end

        end
      end
    end
  end
end
