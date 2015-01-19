def remote_file_exists?(path)
  invoke_command("if [ -e '#{full_path}' ]; then echo -n 'true'; fi") do |ch, stream, out|
    return out == 'true'
  end
  return false
end

def remote_file_content_same_as?(path, content)
  invoke_command("md5sum #{path} | awk '{ print $1 }'") do |ch, stream, out|
    return out.strip == Digest::MD5.hexdigest(content).strip
  end
  return false
end

def remote_file_differs?(path, content)
  !(remote_file_exists?(path) && remote_file_content_same_as?(path, content))
end

set :application, package_json["name"] unless defined? application
set :app_command, package_json["main"] || "index.js" unless defined? app_command
set :app_environment, "" unless defined? app_environment
set :node_env, "production" unless defined? node_env
set :upstart_job_name, lambda { "#{application}-#{node_env}" } unless defined? upstart_job_name
set :upstart_file_path, lambda { "/etc/init/#{upstart_job_name}.conf" } unless defined? upstart_file_path

_cset(:upstart_file_contents) {
  <<EOD
#!upstart
description "#{application} node app"
author      "capistrano"

start on runlevel [2345]
stop on shutdown

respawn
respawn limit 99 5
kill timeout #{kill_timeout}

script
  cd #{current_path} && exec sudo -u #{node_user} NODE_ENV=#{node_env} #{app_environment} #{node_binary} #{current_path}/#{app_command} 2>> #{stderr_log_path} 1>> #{stdout_log_path}
end script
EOD
}

namespace :nodejs do

  desc 'Install node packages in shared directory'
  task :install_packages do
    on roles fetch(:app) do
      execute :mkdir, '-p', "#{shared_path}/node_modules"
      execute :ln, '-s', "#{shared_path}/node_modules", "#{release_path}/node_modules"
      execute "cd #{release_path} && npm install --loglevel warn"
    end
  end

  task :check_upstart_config do
    on roles fetch(:app) do
      create_upstart_config if remote_file_differs?(upstart_file_path, upstart_file_contents)
    end
  end

  desc "Create upstart script for this node app"
  task :create_upstart_config do
    on roles fetch(:app) do
      temp_config_file_path = "#{shared_path}/#{application}.conf"
      # Generate and upload the upstart script
      put upstart_file_contents, temp_config_file_path

      # Copy the script into place and make executable
      sudo "cp #{temp_config_file_path} #{upstart_file_path}"
    end
  end

end
