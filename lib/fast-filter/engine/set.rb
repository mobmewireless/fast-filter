
require 'redis'
require 'fast-filter/engine'

module FastFilter
  class SetEngine < Engine
    def initialize(options = {})
      options[:server] ||= {}
      options[:server][:db] = 1
      options[:server][:host] = "localhost"
      options[:server][:port] = 6379
      
      super(options)
    end
      
    def connect
      begin
        @redis = Redis.new(:host => options[:server][:host], :port => options[:server][:port])
        @redis.select options[:server][:db]
      rescue Errno::ECONNREFUSED
        raise Errno::ECONNREFUSED, "Cannot connect to Redis instance at #{host}:#{port}"
      end
    end
    
    def disconnect
     @redis.quit
     @redis = nil
    end
    
    def connected?
      @redis
    end
    
    def add(namespace, value, options={})
      if validate(namespace, value)
        bucket = "#{namespace}"
        
        @redis.sadd bucket, value
      end
    end
    
    def delete(namespace, value, options={})
      if validate(namespace, value)
        bucket = "#{namespace}"
        
        @redis.srem bucket, value
      end
    end
    
    def filter(namespace, value, options={})
      if validate(namespace, value)
        bucket = "#{namespace}"
        
        !(@redis.sismember bucket, value)
      else
        false
      end
    end
    
    def validate(namespace, value)
      raise ArgumentError, "Namespace should be a string" unless namespace.is_a? String
      true
    end
  end
end
