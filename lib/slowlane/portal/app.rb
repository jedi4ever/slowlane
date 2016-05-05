require_relative './util.rb'
require "spaceship"

module Slowlane
  module Portal
    class App < Thor

      desc "list", "List apps"
      class_option :team , :default => '<team>' , :required => true
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        Spaceship::Portal.app.all.find_all do |app|
          require 'pp'
          detail=[]
          detail << app.app_id
          detail << app.platform
          detail << app.prefix
          detail << app.is_wildcard
          detail << app.bundle_id
          detail << app.name
          puts detail.join("|")
        end


      end

    end
  end
end
