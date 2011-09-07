# encoding: utf-8
Kernel.load File.expand_path('../lib/guard/reloader/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'guard-reloader'
  s.version     = Guard::ReloaderVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Fajar Firdaus']
  s.email       = ['fajarmf@gmail.com']
  s.homepage    = 'https://github.com/fajarmf/Rails-Autotester'
  s.summary     = 'Guard gem that reload file then run test'
  s.description = 'Guard::Reloader automatically load class definition then run your tests on file modification.'

  s.required_rubygems_version = '>= 1.3.6'
#  s.rubyforge_project         = 'guard-reloader'

  s.add_dependency 'guard',     '>= 0.2.2'
  s.add_dependency 'test-unit', '~> 2.2'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README]
  s.require_path = 'lib'
end
