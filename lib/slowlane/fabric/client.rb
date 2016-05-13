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

      def initialize
        self.agent = Mechanize.new

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

          self.agent.get(uri, parameters, referer, headers)

          return self.agent.page
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

      def list_devices(distribution_list)
        people = list_people(distribution_list)

        people_list = []

        people.each do |person|
          people_list << person.id
        end

        self.agent.post('/dashboard/team/export/devices/', { "members" => people_list.join('|'), "csrfmiddlewaretoken" => self.agent.page.parser.css("[name='csrfmiddlewaretoken']")[0]['value'] } )

        device_list = self.agent.page.body.split( /\r?\n/ )

        # Remove first one
        device_list.shift

        devices = []

        device_list.each do |dev|
          #puts dev

          device = Device.new
          device.udid = dev.split(/\t/)[0]
          device.name = dev.split(/\t/)[1]

          devices << device
        end

        devices
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

      def find_app_by_bundle_id(bundle_id)
        apps = list_apps()
        apps.find { |app| app['bundle_identifier'] == bundle_id }
      end

      def list_testers(app_id)
        bootstrap
        page = get("/api/v2/organizations/#{self.team_id}/apps/#{app_id}/beta_distribution/testers_in_organization?include_developers=true")

        testers = JSON.parse(page.body)

        return testers['testers']
      end

      def list_people(group)
        bootstrap

        apps = list_apps

        all_testers = {}

        apps.each do |app|
          testers = list_testers (app['id'])

          #
          # For each tester go through it's devices and add them
          #

          testers.each do |tester|

            #
            # If tester is not yet in, create it
            #

            if all_testers[tester['id']].nil?

              person = Person.new
              person.id = tester['id']
              person.name = tester['name']
              person.email = tester['email']
              person.groups = []
              person.devices = {}

              add_group = false

              if tester['groups']
                groups = tester['groups']

                groups.each do |current_group|

                  person_group = Group.new
                  person_group.id = current_group['id']
                  person_group.name = current_group['name']
                  person_group.alias = current_group['alias']

                  person.groups << person_group

                  if person_group.name == group or person_group.alias == group
                    add_group = true
                  end
                end
              end

              if (add_group == true or group.nil?) and !person.name.empty?
                all_testers[person.id] = person
              end
            else
              person = all_testers[tester['id']]
            end

            append_devices(person, tester['devices'])
          end
        end

        return all_testers
      end

      def list_devices(group)
        bootstrap

        testers = list_people(group)

        devices = {}

        testers.each do |id, tester|
          devices = devices.merge (tester.devices)
        end

        return devices.values
      end

      def list_groups
        testers = list_people(nil)

        groups = {}

        testers.each do |id, tester|
          tester.groups.each do |group|
            groups[group.id] = group
          end
        end

        return groups.values
      end

      private

      def append_devices (person, devices)

        if devices.nil?
          return nil
        end

        devices.each do |device|

          if person.devices[device['identifier']].nil?
            current_device = Device.new
            current_device.manufacturer = device['manufacturer']
            current_device.model = device['model']
            current_device.os_version = device['os_version']
            current_device.identifier = device['identifier']
            current_device.name = device['name']
            current_device.platform = device['platform']
            current_device.model_name = device['model_name']

            person.devices[current_device.identifier] = current_device
          end

        end
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

          session = self.agent.post('https://fabric.io/api/v2/session', { "email" => self.username, "password" => self.password }, { 'X-CRASHLYTICS-DEVELOPER-TOKEN' => self.developer_token, 'X-CSRF-Token' => self.csrf_token, 'X-Requested-With' => 'XMLHttpRequest' } )

        rescue Mechanize::ResponseCodeError => ex
          message = JSON.parse(ex.page.body)

          unless message['message'].nil?
            puts message['message']
          end
        end

        self.login_data = JSON.parse(self.agent.page.body)

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
          #puts team['name']

          if team['alias'] == self.team or team['name'] == self.team
            self.team_id = team['id']

            break
          end
        end

        if self.team_id.nil?
          #raise UnknownTeamError
          raise Error
        end

        #puts "SELECTED TEAM: #{self.team_id}"
      end

    end
  end
end
