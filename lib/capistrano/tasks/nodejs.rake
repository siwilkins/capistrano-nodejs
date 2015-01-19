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

package_json = MultiJson.load(File.open("package.json").read) rescue {}

set :application, fetch(:application, package_json["name"])
set :app_command, fetch(:app_command, (package_json["main"] || "index.js"))
set :app_environment, fetch(:app_command, "")
set :node_env, fetch(:node_env, "production")
set :node_user, fetch(:node_user, "deploy")
set :node_binary, fetch(:node_binary, "/usr/bin/nodejs")
set :upstart_job_name, fetch(:upstart_job_name, "#{fetch(:application)}-#{fetch(:node_env)}")
set :upstart_file_path, fetch(:upstart_file_path, "/etc/init/#{fetch(:upstart_job_name)}.conf")
set :kill_timeout, fetch(:kill_timeout, 5)
set :stderr_log_path, lambda { "#{shared_path}/log/#{node_env}.err.log" }
set :stdout_log_path, lambda { "#{shared_path}/log/#{node_env}.out.log" }

set :upstart_file_contents, lambda {
<<EOD
#!upstart
description "#{fetch(:application)} node app"
author      "capistrano"

start on runlevel [2345]
stop on shutdown

respawn
respawn limit 99 5
kill timeout #{fetch(:kill_timeout)}

script
  cd #{current_path} && exec sudo -u #{fetch(:node_user)} NODE_ENV=#{fetch(:node_env)} #{fetch(:app_environment)} #{fetch(:node_binary)} #{current_path}/#{fetch(:app_command)} 2>> #{fetch(:stderr_log_path)} 1>> #{fetch(:stdout_log_path)}
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
