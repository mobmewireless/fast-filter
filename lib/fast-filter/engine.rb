
module FastFilter
  class Engine
    attr_accessor :options
    
    def self.load(name)
      require_relative "engine/#{name}"
      FastFilter.const_get("#{name.split('-').collect { |item| item.capitalize }.join}Engine")
    end
    
    def initialize(options = {})
      self.options = options
    end
    
    def connect
      raise NotImplementedError, "Any engine must implement the connect method."
    end
    
    def disconnect
      raise NotImplementedError, "Any engine must implement the disconnect method."
    end
    
    def connected?
      raise NotImplementedError, "Any engine must implement the connected? method."
    end
    
    def add(namespace, value, options={})
      raise NotImplementedError, "Any engine must implement the add method."
    end
    
    def delete(namespace, value, options={})
      raise NotImplementedError, "Any engine must implement the delete method."
    end
    
    # Returns TRUE => NOT IN THE DB
    # =>  FALSE => IN THE DB
    def filter(namespace, value, options={})
      raise NotImplementedError, "Any engine must implement the filter method."
    end

    def count(namespace)
      raise NotImplementedError, "Any engine must implement the count method."
    end
    
    def check(namespace, value, options={})
      !filter(namespace, value, options)
    end
  end
end
