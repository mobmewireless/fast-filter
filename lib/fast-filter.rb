
require 'fast-filter/operation'
require 'fast-filter/engine'

module FastFilter
  ENGINES = ['bitmap', 'bloom', 'set', 'disk']
  DEFAULT_ENGINE = 'bitmap'
  DEFAULT_NAMESPACE = "ff:bucket"
end
