require_relative './util.rb'
require "spaceship"
require 'terminal-table'

module Slowlane
  module Itunes
    class App < Thor

      desc "list", "List apps"
      class_option :team , :default => '<team>' , :required => true
      def list()

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        headings = ['appleId', 'name', 'vendor_id', 'bundle_id', 'last_modified', 'issues_count']
        rows = []
        Spaceship::Tunes::Application.all.collect do |app|
          row = []
          row << app.apple_id
          row << app.name
          row << app.vendor_id
          row << app.bundle_id
          row << app.last_modified
          row << app.issues_count
          #pp app.live_version
          #pp app.edit_version
          #pp app.edit_version.candidate_builds unless app.edit_version.nil?
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

      desc "info", "info of app <bundle_id>"
      class_option :team , :default => '<team>' , :required => true
      def info(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        headings = ['description', 'value' ]
        rows = []
        app = Spaceship::Tunes::Application.find(bundle_id)
        rows << %W(name #{app.name})
        rows << %W(apple_id #{app.apple_id})
        rows << %W(bundle_id #{app.bundle_id})
        rows << %W(last_modified #{app.last_modified})
        detail = app.details
        #require 'pp'
        rows << %W(primary_category #{detail.primary_category})
        rows << %W(secondary_category #{detail.secondary_category})
        #pp app.details

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

    end

  end
end
