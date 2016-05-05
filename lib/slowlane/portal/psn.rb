require_relative './util.rb'
require "spaceship"


module Slowlane
  module Portal
    class Psn < Thor

      desc "list", "List push notifications"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        Spaceship::Portal.certificate.all.find_all do |psn|
          require 'pp'
          puts psn.kind_of? Spaceship::Portal::Certificate::ProductionPush
          pp psn unless !psn.is_push?

        end
      end
    end
  end
end
