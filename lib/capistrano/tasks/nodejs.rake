namespace :nodejs do

  desc 'Install node packages in shared directory'
  task :install_packages do
    run "ln -s #{shared_path}/node_modules #{release_path}/node_modules"
    run "cd #{release_path} && npm install --loglevel warn"
  end

end
