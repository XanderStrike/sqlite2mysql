# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqlite2mysql/version'

Gem::Specification.new do |spec|
  spec.name          = 'sqlite2mysql'
  spec.version       = Sqlite2mysql::VERSION
  spec.authors       = ['Alexander Standke']
  spec.email         = ['xanderstrike@gmail.com']

  spec.summary       = 'Simple tool to convert sqlite3 to mysql'
  spec.description   = "Call `sqlite2mysql sqlite_file.db [mysqlname]`\nIf not specified, mysqlname will be the sqlite filename"
  spec.homepage      = 'https://github.com/XanderStrike/sqlite2mysql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_runtime_dependency 'mysql2', '~> 0'
  spec.add_runtime_dependency 'sqlite3', '~> 1'
end
