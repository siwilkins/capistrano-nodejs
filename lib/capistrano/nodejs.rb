load File.expand_path('../tasks/nodejs.rake', __FILE__)

require 'capistrano/setup'
require 'capistrano/deploy'

after "deploy:updated", "nodejs:install_packages"
after "deploy:reverted", "nodejs:install_packages"
