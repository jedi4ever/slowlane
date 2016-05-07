require 'spaceship'
require_relative './util.rb'
require 'terminal-table'

module Slowlane
  module Itunes
    class Tester < Thor

      desc "list", "List apps"
      def list()
        require "spaceship"

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        headings = ['id', 'email', 'type', 'first_name', 'last_name']
        rows = []

        #devices=[{"model"=>"iPhone 6s", "os"=>"iOS", "osVersion"=>"9.3.1", "name"=>nil}],
        #latest_install_app_id=926729916,
        #latest_install_date=1461928193404,
        #latest_installed_build_number="120",
        #latest_installed_version_number="3.0">

        Spaceship::Tunes::Tester::External.all.each do |tester|
          row = %W(#{tester.tester_id} #{tester.email} external #{tester.first_name} #{tester.last_name})
          rows << row
        end

        Spaceship::Tunes::Tester::Internal.all.each do |tester|
          row = %W(#{tester.tester_id} #{tester.email} internal #{tester.first_name} #{tester.last_name})
          rows << row
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

    end
  end
end
