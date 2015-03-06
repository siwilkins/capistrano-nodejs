# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/nodejs/version'

Gem::Specification.new do |gem|
  gem.name          = 'capistrano-nodejs'
  gem.version       = Capistrano::Nodejs::VERSION
  gem.authors       = ['Si Wilkins']
  gem.email         = ['si.wilkins@gmail.com']
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Capistrano plugin for deployment of node.js applications

    * Provides cap deploy functionality for your node app
    * Installs node packages (npm install) during deploys, using a shared folder for speed
    * Automatically creates upstart scripts for your node apps
    * Provides tasks for starting (cap node:start) and stopping (cap node:stop) your node app
    EOF
  gem.summary       = 'Capistrano plugin for deployment of node.js applications'
  gem.homepage      = 'https://github.com/siwilkins/capistrano-nodejs'
  gem.licenses      = ['MIT']
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", "=~ 3.3.5"

end
