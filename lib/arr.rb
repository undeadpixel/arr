require "arr/version"

require 'socket'
require 'json'

require 'arr/connection'
require 'arr/r_object'
require 'arr/na_class'

module Arr

  # general vars
  @@interpreter_query_timeout = 60
  @@server_accept_timeout = 5

  class << self
    attr_accessor :interpreter_query_timeout, :server_accept_timeout
  end

  # configure block
  def self.configure(&block)
    yield self
  end

  # r sources helper
  def self.r_sources_dir_path
    File.expand_path("../../r", __FILE__)
  end

  class Error < ::StandardError; end

end
