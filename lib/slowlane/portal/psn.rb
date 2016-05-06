require_relative './util.rb'
require "spaceship"
require 'terminal-table'


module Slowlane
  module Portal
    class Psn < Thor

      desc "list", "List push notifications"
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
          rows << row unless !psn.is_push?
          if psn.kind_of? Spaceship::Portal::Certificate::ProductionPush
            row << 'production'
          else
            row << 'development'
          end
        end

         table = Terminal::Table.new :headings => headings,  :rows => rows
         puts table

      end

      desc "create", "create push keypairs"
      def create()

        keypair=Spaceship::Portal.certificate.create_certificate_signing_request()
        require 'pp'
        puts keypair[0].to_text()
        #puts keypair[0].to_der()
        puts keypair[0].to_pem()
        puts keypair[1].to_text()

        #csr, pkey = Spaceship::Portal::Certificate.create_certificate_signing_request
        #certificate = Spaceship::Portal::Certificate::ProductionPush.create!(csr: csr, bundle_id: 'net.sunapps.151')
      end

    end

  end
end
