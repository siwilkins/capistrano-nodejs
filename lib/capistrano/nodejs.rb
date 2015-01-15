load File.expand_path('../tasks/nodejs.rake', __FILE__)

after "deploy:updated", "nodejs:install_packages"
after "deploy:reverted", "nodejs:install_packages"
