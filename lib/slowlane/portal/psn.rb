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
