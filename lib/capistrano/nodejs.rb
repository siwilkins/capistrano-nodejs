load File.expand_path('../tasks/nodejs.rake', __FILE__)

before "deploy:create_symlink", "nodejs:install_packages"
