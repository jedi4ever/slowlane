require_relative './util.rb'
require "spaceship"
require 'terminal-table'

module Slowlane
  module Itunes
    class Build < Thor

      class_option :team , :default => '<team>' , :required => true

      desc "current", "Shows current build for a particular app <id>"
      def current(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(bundle_id)

        rows = []
        headings = %w{version platform live status release_on_approval}
        version=app.live_version
        if !version.nil?
          row = %W(#{version.version} #{version.platform} #{version.is_live} #{version.raw_status} #{version.release_on_approval})
          rows << row unless app.live_version.nil?
        end

        version=app.edit_version
        if !version.nil?
          row = %W(#{version.version} #{version.platform} #{version.is_live} #{version.raw_status} #{version.release_on_approval})
          rows << row 
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

      end


      desc "list", "List versions for a particular app <bundle_id>"
      def list(bundle_id)

        c=Utils.credentials(options)
        Spaceship::Tunes.login(c.username,c.password)

        t=Utils.team(options)
        Spaceship::Tunes.client.team_id=t

        app = Spaceship::Tunes::Application.find(bundle_id)
        headings = %w{app_name platform train_version build_version upload_date processing valid}
        rows = []
        app.build_trains.each do |key,value|
          builds = app.all_builds_for_train(train: key)
          builds.each do |build|
            row = %W(#{build.app_name} #{build.platform} #{build.train_version} #{build.build_version} #{Time.at(build.upload_date/1000)} #{build.processing} #{build.valid} )
            rows << row
          end
        end

        table = Terminal::Table.new :headings => headings,  :rows => rows
        puts table

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
        require "pathname"
        plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(filename) || {}
        platform = plist["DTPlatformName"]
        platform = "ios" if platform == "iphoneos" # via https://github.com/fastlane/spaceship/issues/247
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(app_id: app.apple_id,
                                                                          ipa_path: filename,
                                                                          package_path: Pathname.new(options[:temp_dir]).realpath.to_s,
                                                                          platform: platform)

        # https://github.com/fastlane/fastlane/blob/1229fc55f004975e94226961ef23bbaa554f82b0/fastlane_core/lib/fastlane_core/itunes_transporter.rb#L267
        transporter = FastlaneCore::ItunesTransporter.new(c.username,c.password)
        # TODO easier way to disable loggs
        #require 'logger'
        #transporter.log = Logger.new(nil)
        #ENV['CIRCLECI']='yes'

        # TODO why need to specify this
        # https://github.com/fastlane/fastlane/issues/2294
        # Could not start delivery: all transports failed diagnostics
        ENV["DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS"] = "-t DAV"
        result = transporter.upload(app.apple_id, package_path)
        if !result
          exit(-1)
        end
      end


    end

  end
end
