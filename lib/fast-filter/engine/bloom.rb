
require 'redis'
require 'bloomfilter-rb'
require 'digest/sha1'
require 'fast-filter/engine'

module FastFilter
  class BloomEngine < Engine
    attr_accessor :bloom_connections
    
    # See: http://www.igvita.com/2008/12/27/scalable-datasets-bloom-filters-in-ruby/
    # This default filter size assumes a 100M key size and is 100M * 15 bits
    FILTER_SIZE = 1_500_000_000 # in bits. This is 178M
    
    # See: http://www.igvita.com/2008/12/27/scalable-datasets-bloom-filters-in-ruby/
    FILTER_HASHES = 11
    
    def initialize(options = {})
      options[:server] ||= {}
      options[:server][:db] = 1
      options[:server][:host] = "localhost"
      options[:server][:port] = 6379
      
      @bloom_connections = {}
      
      super(options)
    end
    
    def connect(namespace = nil)
      namespace ||= FastFilter::DEFAULT_NAMESPACE
      
      @bloom_connections[namespace] ||= ::BloomFilter::Redis.new(
        :server => options[:server],
        :namespace => namespace,
        :seed => Digest::SHA1.hexdigest(namespace).hex,
        :eager => true,
        :size => FastFilter::BloomEngine::FILTER_SIZE,
        :hashes => FastFilter::BloomEngine::FILTER_HASHES
      )
    end
    
    def disconnect
      @bloom_connections = {}
    end
    
    def connected?
      @bloom_connections.empty?
    end
    
    def add(namespace, value, options={})
      bloom = connect(namespace)
      
      bloom.insert(value)
    end
    
    def delete(namespace, value, options={})
      bloom = connect(namespace)
      
      bloom.delete(value)
      
      # raise NotImplementedError, "Bloom filter does not allow you to delete items"
    end
    
    # Returns TRUE => NOT IN THE DB
    # =>  FALSE => IN THE DB
    def filter(namespace, value, options={})
      bloom = connect(namespace)
      
      !(bloom.include?(value))
    end
  end
end
