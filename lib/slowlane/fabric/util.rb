require 'ostruct'

class Utils
  def self.credentials(options)

    credentials = OpenStruct.new

    if ENV['SLOWLANE_FABRIC_USERNAME']
      credentials.username=ENV['SLOWLANE_FABRIC_USERNAME']
    else
      if options[:username] == '<username>'
        puts "username is required"
        exit(-1)
      else
        credentials.username=options[:username]
      end
    end

    if ENV['SLOWLANE_FABRIC_PASSWORD']
      credentials.password=ENV['SLOWLANE_FABRIC_PASSWORD']
    else
      if options[:password] == '<password>'
        puts "password is required"
        exit(-1)
      else
        credentials.password=options[:username]
      end
    end
    return credentials
  end

  def self.team(options)

    if ENV['SLOWLANE_FABRIC_TEAM']
      team=ENV['SLOWLANE_FABRIC_TEAM']
    else
      if options[:team] == '<team>'
        puts "team is required"
        exit(-1)
      else
        team=options[:team]
      end
    end
    return team
  end

end
