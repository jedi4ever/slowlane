require_relative './util.rb'
require "spaceship"

module Slowlane
  module Itunes
    class Build < Thor

      class_option :team , :default => '<team>' , :required => true

      desc "list", "List builds for a particular app <id>"
      option :type , :required => true
      def list(id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(id)
        require 'pp' 
        if (options[:type] == 'live') 
          pp app.live_version
        end

        if (options[:type] == 'edit') 
          pp app.edit_version
          pp app.edit_version.candidate_builds unless app.edit_version.nil?
        end

      end


      desc "trains", "List trains for a particular app <id>"
      option :type , :required => true
      def trains(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(bundle_id)
        require 'pp'
        pp app.build_trains

      end

      desc "trainnumbers", "List trainnumbers for a particular app <id>,train <train>"
      option :type , :required => true
      def trainnumbers(id,train_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(id)
        builds = app.all_builds_for_train(train: train_id)
        builds.each do |build|
          puts "#{build.train_version}|#{build.build_version}|#{build.app_name}|#{build.platform}|#{build.upload_date}|#{build.processing}|#{build.valid}"
        end

      end

      desc 'upload', 'upload ipa <bundle_id> <filename>'
      option :temp_dir, :default => '/tmp' 
      def upload(bundle_id,filename)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(bundle_id)

        require "fastlane_core"
        #plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file("build.ipa"]) || {}
        #platform = plist["DTPlatformName"]
        #platform = "ios" if platform == "iphoneos" # via https://github.com/fastlane/spaceship/issues/247
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(app_id: app.apple_id,
                                                                          ipa_path: filename,
                                                                          package_path: options[:temp_dir],
                                                                          platform: 'ios')

        # https://github.com/fastlane/fastlane/blob/1229fc55f004975e94226961ef23bbaa554f82b0/fastlane_core/lib/fastlane_core/itunes_transporter.rb#L267
        puts package_path
        #transporter = FastlaneCore::ItunesTransporter.new(options[:username],options[:password])
        #result = transporter.upload(app.apple_id, package_path)
      end


    end

  end
end
