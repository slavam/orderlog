# Load the rails application
require File.expand_path('../application', __FILE__)
require 'odbc_utf8'

# Initialize the rails application
Orderlog::Application.initialize!

Encoding.default_internal = 'UTF-8'