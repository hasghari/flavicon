# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'flavicon'
require 'pry'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
