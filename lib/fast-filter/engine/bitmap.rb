
require 'redis'
require 'fast-filter/engine'

module FastFilter
  class BitmapEngine < Engine
    # The maximum bits to store in the bitmap. 
    # This is to prevent unbounded memory usage.
    MAX_OFFSET = 9
    
    def initialize(options = {})
      options[:server] ||= {}
      options[:server][:db] ||= 1
      options[:server][:host] ||= "localhost"
      options[:server][:port] ||= 6379
      
      super(options)
    end
      
    def connect
      begin
        @redis = Redis.new(:host => options[:server][:host], :port => options[:server][:port])
        @redis.select options[:server][:db]
      rescue Errno::ECONNREFUSED
        raise Errno::ECONNREFUSED, "Cannot connect to Redis instance at #{options[:server][:host]}:#{options[:server][:port]}"
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
        bucket = "#{namespace}:#{value.slice(0,1)}"
        offset = value.slice(1, FastFilter::BitmapEngine::MAX_OFFSET).to_i
        
        @redis.setbit bucket, offset, 1
      end
    end
    
    def delete(namespace, value, options={})
      if validate(namespace, value)
        bucket = "#{namespace}:#{value.slice(0,1)}"
        offset = value.slice(1, FastFilter::BitmapEngine::MAX_OFFSET).to_i
        
        @redis.setbit bucket, offset, 0
      end
    end
    
    def filter(namespace, value, options={})
      if validate(namespace, value)
        bucket = "#{namespace}:#{value.slice(0,1)}"
        offset = value.slice(1, FastFilter::BitmapEngine::MAX_OFFSET).to_i
        
        (@redis.getbit bucket, offset) == 0
      else
        false
      end
    end

    def count(namespace)
      total_dnd_count = 0
      (0..9).each { |bucket| total_dnd_count += @redis.bitcount "#{namespace}:#{bucket}" }
      return total_dnd_count
    end
    
    def validate(namespace, value)
      raise ArgumentError, "Namespace should be a string" unless namespace.is_a? String
      raise ArgumentError, "Value should be castable as a non-zero integer" if value.to_i == 0
      true
    end
  end
end
