require_relative "active_force/client.rb"
require_relative "active_force/sobject.rb"

module Salesforce

  def self.const_missing(name)
    sobject = ActiveForce::Client.instance.sobjects.detect { |sobj| sobj.downcase == name.to_s.downcase }
    if sobject
      klass = Class.new(ActiveForce::Sobject)
      self.const_set sobject, klass
    else
      super
    end
  end

end