module ActiveForce
  class Config
    include Singleton
    attr_reader :username, :password, :consumer_key, :consumer_secret, :security_token

    def initialize
      config = YAML.load(File.read('lib/active_force/config.yml'))

      [:username, :password, :consumer_key, :consumer_secret, :security_token].each do |att|
        instance_variable_set("@#{att.to_s}", config[att.to_s])
      end

    end

  end
end