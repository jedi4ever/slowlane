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

      desc "add_device","add_device <bundle_id> <device_udid>"
      def add_device(bundle_id,device_udid)
        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        puts "Note: only adding devices to distribution adhoc profiles"

        device=Spaceship.device.find_by_udid(device_udid)
        if device.nil?
          puts "No device with udid #{device_udid} found"
          exit(-1)
        end

        profiles = Spaceship.provisioning_profile.find_by_bundle_id(bundle_id)
        distribution_profiles = profiles.select do |profile|
          profile.type == "iOS Distribution" and profile.is_adhoc?
        end

        if distribution_profiles.size() == 0
          puts "We found no provisioning profiles for bundle_id #{bundle_id}"
          exit(-1)
        end

        if distribution_profiles.size() > 1
          puts "We found multiple provisioning profiles for bundle_id #{bundle_id}"
          exit(-1)
        end

        profile=distribution_profiles.first
        profile.devices.push(device)
        profile.update!

        puts "device with udid #{device_udid} added to provisioning profile #{profile.name}(#{bundle_id})"

      end

      #option :platform,:default => 'ios', :banner => '<adhoc,limited,store>'
      desc "download", "download provisioning profile <bundle_id>"
      option :distribution_type,:required => true , :banner => '<adhoc,limited,store>'
      def download(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        profiles = Spaceship.provisioning_profile.find_by_bundle_id(bundle_id)

        distribution_profiles = profiles.select do |profile|
          if profile.distribution_method == "store"
            if options[:distribution_type] == "adhoc"
              profile.is_adhoc?
            else
              !profile.is_adhoc?
            end
          else
            return false
          end
        end

        if distribution_profiles.size() == 0
          puts "We found no provisioning profiles for bundle_id #{bundle_id}"
          exit(-1)
        end

        if distribution_profiles.size() > 1
          puts "We found multiple provisioning profiles for bundle_id #{bundle_id}"
          exit(-1)
        end

        profile=distribution_profiles.first

        filename = "#{profile.uuid}.mobileprovision"
        puts "writing provisioning profile #{profile.name}(#{bundle_id}) to #{filename}"
        File.write("#{profile.uuid}.mobileprovision", profile.download)

      end

      desc "create", "Create a new profile <bundle_id>"
      def create(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        cert = Spaceship.certificate.production.all.first
        #require 'pp'
        #pp cert

        profile = Spaceship.provisioning_profile.AdHoc.create!(bundle_id: bundle_id, certificate: cert)
        # Print the name and download the new profile
        puts "Created Profile " + profile.name
        profile.download


      end

      desc "list", "List profiles"
      def list()

        c=Utils.credentials(options)
        Spaceship::Portal.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Portal.client.team_id=t

        rows = []
        headings = [ 'uuid', 'id', 'distribution_method', 'name' ,'platform','type','bundle_id']
        Spaceship::Portal.provisioning_profile.all.find_all do |profile|
          row = []
          row << profile.uuid
          row << profile.id
          row << profile.distribution_method
          row << profile.name
          #TODO Spaceship - separate this type
          row << profile.type.split(' ')[0].downcase
          row << profile.type.split(' ')[1].downcase
          row << profile.app.bundle_id

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
