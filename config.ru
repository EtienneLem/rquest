require File.expand_path('../config/application',  __FILE__)

use Rack::Deflater

# Sprockets
map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/javascripts'
  environment.append_path 'app/assets/stylesheets'
  Stylus.setup environment
  Stylus.use :nib

  run environment
end

# Main application
map '/' do
  run Rquest::App
end
