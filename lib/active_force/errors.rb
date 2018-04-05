module ActiveForce

  class ActiveForceError < StandardError; end;

  class ConnectionError < ActiveForceError
    attr_reader :error, :error_code

    def initialize(message = nil, error = nil, error_code = nil)
      @error, @error_code = error, error_code
      super(message)
    end

  end

  # raised when ActiveForce cannot find a record by given ids or set of ids
  class RecordNotFound < ActiveForceError

    attr_reader :model, :primary_key, :id

    def initialize(message = nil, model = nil, primary_key = nil, id = nil)
      @model, @primary_key, @id = model, primary_key, id
      super(message)
    end

  end

end