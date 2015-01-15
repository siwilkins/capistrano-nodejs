namespace :nodejs do

  desc 'Install node packages in shared directory'
  task :install_packages do
    on roles fetch(:app) do
      execute :ln, '-s', "#{shared_path}/node_modules", "#{release_path}/node_modules"
      execute "cd #{release_path} && npm install --loglevel warn"
    end
  end

end
