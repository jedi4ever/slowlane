require_relative './util.rb'
require "spaceship"
require 'terminal-table'


module Slowlane
  module Portal
    class Certificate < Thor

      desc "list", "List certificates"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        rows = []
        headings=%w(name status created expires owner_type owner_name owner_id type_display_id can_download type)
        Spaceship::Portal.certificate.all.find_all do |psn|
          row = []
          row << psn.name
          row << psn.status
          row << psn.created
          row << psn.expires
          row << psn.owner_type
          row << psn.owner_name
          row << psn.owner_id
          row << psn.type_display_id
          row << psn.can_download
          # TODO add this type to spaceship
          type = psn.class.name.gsub(/Spaceship::Portal::Certificate/,'').gsub(/::/,'')
          if psn.type_display_id == '3BQKVH9I2X'
            type = 'OldPush'
          end
          row << type
          rows << row
        end

         table = Terminal::Table.new :headings => headings,  :rows => rows
         puts table

      end

    end

  end
end
