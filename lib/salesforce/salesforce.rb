require_relative '../active_force/client.rb'

module Salesforce

  def self.const_missing(name)
    ap name
    sobject = ::ActiveForce::Client.instance.sobjects.detect { |sobj| sobj.downcase == name.to_s.downcase }
    if sobject
      klass = Class.new(Salesforce::Sobject)
      self.const_set sobject, klass 
    else
      super
    end
  end

end