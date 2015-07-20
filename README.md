Fast Filter is a library built on top of Redis that provides many filtering engines for fast and efficient filtering of large datasets.

# Dependencies

* Redis server version at least 2.3.0 (a4fdc3c0:0)
* Ruby 2.2.2
* redis rubygem
* bloomfilter-rb rubygem (does not work under JRuby)

# Using:
Add this to your Gemfile:

    gem 'fast-filter', :git => 'git://github.com/mobmewireless/fast-filter.git'

Then:

    require 'fast-filter'

To: require an engine:

    require 'fast-filter/engine/bitmap'
    
    options = {
    	:engine => 'bitmap' #one of bitmap, set or bloom
    	:server => { # redis server options
    		:host => 'localhost'
    		:port => 6379
    		:db =>	1
    	}
    }

Operations:

    fast_filter_op = FastFilter::Operation.new(options)
    fast_filter_op.add("9876543210")
    fast_filter_op.filter("9876543210")
    fast_filter_op.delete("9876543210")
    fast_filter_op.close

# Which engine should I choose?

As a rule of thumb:

* When data size is small (< 10M), use sets.
* When data size is large but a simple list of small integers, use bitmap.
* When data size is large and complex and you don't need to delete from the filter, use bloom.
* When data size is large and complex, and filtering can be a bit slow, use disk.
* Sets, Bitmaps and Blooms use Redis.

Some data to help you choose:

    wc -l 14.csv = 7631928
    wc -l base.csv = 1000000

Bitmap:

    ruby -rubygems fast_filter_shell.rb add --engine bitmap 14.csv  556.92s user 152.28s system 63% cpu 18:41.26 total
    ruby -rubygems fast_filter_shell.rb filter --engine bitmap base.csv  73.79s user 20.08s system 67% cpu 2:18.51 total

Space: 570MB (constant)

Bloom:

    ruby -rubygems fast_filter_shell.rb add --engine bloom 14.csv  4466.57s user 1621.11s system 58% cpu 2:53:27.80 total
    ruby -rubygems fast_filter_shell.rb filter --engine bloom base.csv  356.81s user 128.92s system 61% cpu 13:12.04 total

Space: 350MB (constant, eager loaded)

Set:

    ruby -rubygems fast_filter_shell.rb add --engine set 14.csv  491.68s user 153.02s system 61% cpu 17:33.70 total
    ruby -rubygems fast_filter_shell.rb filter --engine set base.csv  68.48s user 20.08s system 63% cpu 2:18.44 total

Space: 410 MB (scales with size)

# Credits

Much of the initial idea and the bitmap filter code was written by Nanda Sankaran ([na9da](https://github.com/na9da)). Vishnu Gopal ([vishnugopal](https://github.com/vishnugopal)) added more filter backends and standardized the filter interface.


