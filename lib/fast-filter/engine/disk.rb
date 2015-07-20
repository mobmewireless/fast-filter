
require 'fast-filter/engine'
require 'fileutils'

module FastFilter
  class DiskEngine < Engine
    
    # What do I call the file where data is stored?
    DISK_ENDPOINT_FILE = 'data'
    
    def initialize(options = {})
      options[:path] ||= "/usr/local/var/db/fastfilter/diskengine"
      options[:split_depth] ||= 6
      
      super(options)
    end
      
    def connect
    end
    
    def disconnect
    end
    
    def connected?
      true
    end
    
    def add(namespace, value, options={})
      if validate(namespace, value)
        file_path = storable_path(namespace, value)
        
        ensure_exists_path(file_path)
        
        if options[:check_before]
          return if check(namespace, value, options)
        end
        
        append_to_file(file_path, value) 
      end
    end
    
    def delete(namespace, value, options={})
      if validate(namespace, value)
        file_path = storable_path(namespace, value)
        
        return false unless File.exists?(file_path)
        delete_from_file(file_path, value)
      end
    end
    
    def filter(namespace, value, options={})
      if validate(namespace, value)
        file_path = storable_path(namespace, value)
        
        return true unless File.exists?(file_path)
        
        not (grep_in_file(file_path, value))
      end
    end
    
    private
    
    # Splits by dashes and then by max two letter characters
    # but for a maximum split of options[:split-depth].
    # Returns the path to store content.
    def storable_path(namespace, value)
      content = "#{namespace}-#{value}"
      broken_path = content.split(/-|([\d]{2})/, options[:split_depth]).delete_if { |a| a.empty? }
      "#{options[:path]}/#{File.join(broken_path[0..(options[:split_depth] - 2)])}/#{FastFilter::DiskEngine::DISK_ENDPOINT_FILE}"
    end
    
    def ensure_exists_path(file_path)
      return if File.exists?(file_path)
      create_path(File.dirname(file_path))
      create_file(file_path)
    end
    
    def create_path(path)
      FileUtils.mkdir_p("#{path}")
    end
    
    def create_file(file_path)
      FileUtils.touch("#{file_path}")
    end
    
    def append_to_file(file_path, contents)
      File.open("#{file_path}", 'a') do |f|
        f.write("#{contents}\n")
      end
    end
    
    def grep_in_file(file_path, contents)
      File.open("#{file_path}", 'r') do |f|
        f.each_line do |line|
          return true if line.strip == contents
        end
      end
      false
    end
    
    def delete_from_file(file_path, contents)
      sed_command = "sed -i '' 's/#{contents}//' #{file_path}"
      output = `#{sed_command}`.to_s.strip
      output
    end
    
    def validate(namespace, value)
      raise ArgumentError, "Namespace should be a string" unless namespace.is_a? String
      raise ArgumentError, "Namespace can only contain A-Z, 0-9 and -, #{namespace} given" unless namespace.match /^[a-z0-9\-]+$/i
      raise ArgumentError, "Value can only contain A-Z, 0-9 and -, #{value} given" unless value.to_s.match /^[a-z0-9\-]+$/i
      true
    end
  end
end
