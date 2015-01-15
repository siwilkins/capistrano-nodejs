load File.expand_path('tasks/nodejs.rake')

before "deploy:create_symlink", "nodejs:install_packages"
