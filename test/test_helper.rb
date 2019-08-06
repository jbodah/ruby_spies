# Add lib to load path
$LOAD_PATH.push 'lib', __FILE__
require 'spy'
require 'spy/util'

require 'coveralls'
Coveralls.wear!

require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/spec'
