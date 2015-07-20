require "rspec"

require_relative "../../lib/fast-filter"

# Tests require Redis running at localhost:6379
RSpec.describe FastFilter::Operation do
  let(:bloom_filter) { FastFilter::Operation.new(engine: 'bloom', namespace: 'bloom') }
  let(:bitmap_filter) { FastFilter::Operation.new(engine: 'bitmap', namespace: 'bitmap') }
  let(:disk_filter) { FastFilter::Operation.new(engine: 'disk', namespace: 'disk') }
  let(:set_filter) { FastFilter::Operation.new(engine: 'set', namespace: 'set') }
  
  context "Bloom Filter" do
    it "can be initialized" do
      bloom_filter
    end
    
    it "can add, remove and filter items" do
      bloom_filter.add("9876543210")
      bloom_filter.filter("9876543210")
      bloom_filter.delete("9876543210")
    end
  end
  
  context "Bitmap Filter" do
    it "can be initialized" do
      bitmap_filter
    end
    
    it "can add, remove and filter item" do
      bitmap_filter.add("9876543210")
      bitmap_filter.filter("9876543210")
      bitmap_filter.delete("9876543210")
    end
  end
   
  # Disk Filter is initialized at /usr/local/var/db/fastfilter/diskengine, so
  # that folder may need to be created.
  context "Disk Filter" do
    it "can be initialized" do
      disk_filter
    end
    
    it "can add, remove and filter item" do
      disk_filter.add("9876543210")
      disk_filter.filter("9876543210")
      disk_filter.delete("9876543210")
    end
  end

  context "Set Filter" do
    it "can be initialized" do
      set_filter
    end
    
    it "can add, remove and filter item" do
      set_filter.add("9876543210")
      set_filter.filter("9876543210")
      set_filter.delete("9876543210")
    end
  end
end