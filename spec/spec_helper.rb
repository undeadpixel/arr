# add lib to require path
$: << File.expand_path('../../lib', __FILE__)

require 'arr'

require 'byebug'

# support global requires
require 'support/data_helpers'

RSpec.configure do |c|
  c.include DataHelpers
end
