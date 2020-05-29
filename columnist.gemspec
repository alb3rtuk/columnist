$LOAD_PATH << File.expand_path(File.join('..', 'lib'), __FILE__)

require 'date'

require_relative 'version'

Gem::Specification.new do |s|
    s.name        = 'columnist'
    s.version     = COLUMNIST_VERSION
    s.summary     = 'A tool for building interactive command line reports'
    s.description = 'A quick & easy way to generate reports on the the command line'
    s.authors     = ['Albert Rannetsperger', 'Wes Bailey']
    s.email       = 'alb3rtuk@hotmail.com'
    s.homepage    = 'http://github.com/alb3rtuk/columnist'
    s.license     = 'MIT'
    s.files       = Dir['examples/**/*', 'lib/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
    s.test_files  = Dir['spec/**/*'] & `git ls-files -z`.split("\0")
    s.add_dependency 'colored', '~> 1.2', '>= 1.2.0'
    s.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.0'
end