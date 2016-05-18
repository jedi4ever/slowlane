require 'mechanize'
require 'uri'
require 'json'
require 'logger'

module Slowlane
  module Fabric
    class Client
      attr_accessor :host, :agent
      attr_accessor :username,:password,:team
      attr_accessor :developer_token, :access_token, :csrf_token, :login_data, :team_id

      def agent
        unless @agent
          @agent = ::Mechanize.new
        end
        @agent
      end

      def initialize
        self.host = "fabric.io"
      end

      def get(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{self.host}", uri) unless /^https?/ === uri

        #puts "Requesting: #{uri}"

        unless (self.developer_token.nil?)
          headers['X-CRASHLYTICS-DEVELOPER-TOKEN'] = self.developer_token
        end

        unless (self.access_token.nil?)
          headers['X-CRASHLYTICS-ACCESS-TOKEN'] = self.access_token
        end

        unless (self.csrf_token.nil?)
          headers['X-CSRF-Token'] = self.csrf_token
        end

        headers['X-Requested-With'] = 'XMLHttpRequest'

        3.times do

          agent.get(uri, parameters, referer, headers)

          return agent.page
        end

        #raise NetworkError
        raise Error
      end

      def post(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{self.host}", uri) unless /^https?/ === uri

        #puts "Requesting: #{uri}"

        unless (self.developer_token.nil?)
          headers['X-CRASHLYTICS-DEVELOPER-TOKEN'] = self.developer_token
        end

        unless (self.access_token.nil?)
          headers['X-CRASHLYTICS-ACCESS-TOKEN'] = self.access_token
        end

        unless (self.csrf_token.nil?)
          headers['X-CSRF-Token'] = self.csrf_token
        end

        headers['X-Requested-With'] = 'XMLHttpRequest'
        headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'

        # emails[]:patrick@smalltownheroes.be
        3.times do

          agent.post(uri, parameters, headers)

          return agent.page
        end

        #raise NetworkError
        raise Error
      end

      def put(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{self.host}", uri) unless /^https?/ === uri

        #puts "Requesting: #{uri}"

        unless (self.developer_token.nil?)
          headers['X-CRASHLYTICS-DEVELOPER-TOKEN'] = self.developer_token
        end

        unless (self.access_token.nil?)
          headers['X-CRASHLYTICS-ACCESS-TOKEN'] = self.access_token
        end

        unless (self.csrf_token.nil?)
          headers['X-CSRF-Token'] = self.csrf_token
        end

        headers['X-Requested-With'] = 'XMLHttpRequest'
        headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'

        3.times do

          agent.put(uri, parameters, headers)

          return agent.page
        end

        #raise NetworkError
        raise Error
      end

      #
      # Handles login and CSRF tokens
      #

      def bootstrap

        if (self.csrf_token.nil?)
          csrf!
        end

        #
        # First need developer token
        #
        if (self.developer_token.nil?)
          config!
        end

        #
        # Need to login too
        #
        if (self.access_token.nil?)
          login!
        end
      end

      def list_apps
        bootstrap

        page = get("/api/v2/organizations/#{self.team_id}/apps")

        apps = JSON.parse(page.body)

        return apps
      end

      def list_organizations
        bootstrap

        page = get("/api/v2/organizations")

        organizations = JSON.parse(page.body)

        return organizations
      end

      def list_members
        bootstrap

        page = get("/api/v2/organizations/#{self.team_id}/team_members")

        members = JSON.parse(page.body)

        return members
      end

      def find_group_by_name(name)
        testers = list_testers()
        testers.each do |tester|
          groups=tester['groups']
          groups.each do |group|
            #puts group['name']
            if group['name'] == name
              return group
            end
          end
        end
        return nil

      end

      def find_apps_by_bundle_id(bundle_id)
        apps = list_apps()
        apps.select { |app| app['bundle_identifier'] == bundle_id }
      end

      def find_tester_by_email(email)
        testers = list_testers()
        testers.find { |tester| tester['email'] == email }
      end


      def list_testers(app_id = nil)

        bootstrap

        if app_id.nil?
          app_id = self.list_apps.first['id']
        end

        page = get("/api/v2/organizations/#{self.team_id}/apps/#{app_id}/beta_distribution/testers_in_organization?include_developers=true")

        testers = JSON.parse(page.body)

        return testers['testers']
      end

      def list_tester_devices(tester_id)
        bootstrap

        page = get("/api/v2/organizations/#{self.team_id}/beta_distribution/testers/#{tester_id}/devices")

        data = JSON.parse(page.body)
        return data['devices']

      end


      def list_tester_apps(tester_id)
        bootstrap

        page = get("/api/v2/organizations/#{self.team_id}/beta_distribution/testers/#{tester_id}/apps")

        data = JSON.parse(page.body)
        return data['apps']

      end

      def tester_resend_invitation(app_id,email)
        bootstrap

        page = post("/api/v2/organizations/#{self.team_id}/apps/#{app_id}/beta_distribution/resend_invitation", {
          "emails[]" => email 
        })
        data = JSON.parse(page.body)
        require 'pp'
        pp data
      end


      def tester_invite(app_id,group_id,email)
        bootstrap

        input = URI.encode_www_form( "emails[]" => email)
        page = put("/api/v2/organizations/#{self.team_id}/apps/#{app_id}/beta_distribution/groups/#{group_id}/testers/invite", input)
        data = JSON.parse(page.body)
        require 'pp'
        pp data
      end

      def list_tester_groups(tester_id)
        bootstrap

        page = get("/api/v2/organizations/#{self.team_id}/beta_distribution/testers/#{tester_id}/groups")

        data = JSON.parse(page.body)
        return data['groups']

      end

      def csrf!
        page = get('/login')

        token = page.at('meta[name="csrf-token"]')[:content]

        unless token.nil?
          self.csrf_token = token
        end
      end

      def config!
        page = get ('/api/v2/client_boot/config_data')

        config_object = JSON.parse(page.body)

        unless config_object['developer_token'].nil?
          self.developer_token = config_object['developer_token']
        else
          raise Error
          #raise UnsuccessfulAuthenticationError
        end
      end

      def login!
        begin

          session = agent.post('https://fabric.io/api/v2/session', { "email" => self.username, "password" => self.password }, { 'X-CRASHLYTICS-DEVELOPER-TOKEN' => self.developer_token, 'X-CSRF-Token' => self.csrf_token, 'X-Requested-With' => 'XMLHttpRequest' } )

        rescue Mechanize::ResponseCodeError => ex
          message = JSON.parse(ex.page.body)

          unless message['message'].nil?
            puts message['message']
          end
        end

        self.login_data = JSON.parse(agent.page.body)

        unless self.login_data['token'].nil?
          self.access_token = self.login_data['token']

          select_team!
        else
          raise Error
          #raise UnsuccessfulAuthenticationError
        end
      end

      def select_team!

        if self.login_data['organizations'].nil?
          raise Error
          # raise UnknownTeamError
        end

        teams = self.login_data['organizations']

        teams.each do |team|

          if team['alias'] == self.team or team['name'] == self.team
            self.team_id = team['id']

            break
          end
        end

        if self.team_id.nil?
          #raise UnknownTeamError
          raise Error
        end

      end

    end
  end
end
