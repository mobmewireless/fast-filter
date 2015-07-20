
module FastFilter
  class Operation
    attr_accessor :engine, :options, :namespace
    
    def initialize(options = {})
      self.options = options
      
      options[:engine] ||= FastFilter::DEFAULT_ENGINE
      
      raise ArgumentError, "Engine must be one of: #{FastFilter::ENGINES.join(', ')}" unless FastFilter::ENGINES.include?(options[:engine])
      
      self.namespace = options[:namespace] || FastFilter::DEFAULT_NAMESPACE
      @engine = FastFilter::Engine.load(options[:engine]).new(options)
      connect
    end
    
    def disconnect
      @engine.disconnect
    end
    alias :close :disconnect
    
    def connected?
      @engine.connected?
    end
    
    def connect
      @engine.connect
    end

    def add(value, options = {})
      @engine.add(options[:namespace] || namespace, value, options)
    end

    def delete(value, options = {})
      @engine.delete(options[:namespace] || namespace, value, options)
    end

    # Returns TRUE => NOT IN THE DB
    # =>  FALSE => IN THE DB
    def filter(value, options = {})
      @engine.filter(options[:namespace] || namespace, value, options)
    end

    def count(options = {})
      @engine.count( options[:namespace] || namespace)
    end
    
    # Returns TRUE => IN THE DB
    # =>  FALSE => NOT IN THE DB
    def check(value, options = {})
      not (filter(value, options))
    end
  end
end
