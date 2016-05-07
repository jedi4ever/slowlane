require_relative './util.rb'
require "spaceship"
require 'terminal-table'
require 'openssl'

module Slowlane
  module Portal
    class Profile < Thor

      # https://gist.github.com/mlaster/2854189
      desc "decode", "decode <filename>"
      def decode(filename)

        require 'plist'
        profile = `security cms -D -i '#{filename}'`
        xml = Plist::parse_xml(profile)
        rows = []
        headings = [ 'Key', 'Value']

        rows << [ 'AppIDName', xml['AppIDName'] ]
        rows << [ 'Name', xml['Name'] ]
        rows << [ 'TeamName', xml['TeamName'] ]
        rows << [ 'UUID', xml['UUID'] ]
        rows << [ 'ApplicationIdentifierPrefix', xml['ApplicationIdentifierPrefix'].join(',') ]
        rows << [ 'TeamIdentifier', xml['TeamIdentifier'].join(',') ]
        rows << [ 'Version', xml['Version'] ]
        rows << [ 'TimeToLive', xml['TimeToLive'] ]
        rows << [ 'get-task-allow', xml['Entitlements']['get-task-allow'] ]
        rows << [ 'keychain-access-groups', xml['Entitlements']['keychain-access-groups'].join(',') ]
        rows << [ 'application-identifier', xml['Entitlements']['application-identifier']]
        rows << [ 'aps-environment', xml['Entitlements']['aps-environment']]
        rows << [ 'beta-reports-active', xml['Entitlements']['beta-reports-active']]
        rows << [ 'get-task-allow', xml['Entitlements']['get-task-allow']]
        rows << [ 'com.apple.developer.team-identifier', xml['Entitlements']['com.apple.developer.team-identifier']]
        rows << [ 'CreationDate', xml['CreationDate']]
        rows << [ 'ExpirationDate', xml['ExpirationDate']]
        rows << [ 'ProvisionedDevices', xml['ProvisionedDevices'].join("\n") ] unless xml['ProvisionedDevices'].nil?

        devcerts = xml['DeveloperCertificates']

        decoded_certs = []

        devcerts.each do |data|
          cert = OpenSSL::X509::Certificate.new(data.read)
          decoded_certs << "#{cert.subject},#{cert.not_before}"
        end

        rows << [ 'Certificates', decoded_certs.join("\n") ]
        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end

      desc "device::add","device::add <bundle_id> <device>"
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
