require 'active_force/errors'

module ActiveForce

  def self.configure(&block)
    yield ActiveForce::Config.instance
  end

end