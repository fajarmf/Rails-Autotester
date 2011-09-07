# encoding: utf-8
require 'json'
require 'guard'
require 'guard/guard'
require 'guard/reloader/version'
require 'test/unit/version' unless defined?(::Test::Unit::VERSION)

module Guard
  class Reloader < Guard

    def initialize(watchers=[], options={})
      super
      @options = {
        :all_on_start   => true,
        :all_after_pass => true,
        :keep_failed    => true
      }.update(options)
      ::Guard::UI.info("Guard::Reloader #{ReloaderVersion::VERSION} setting up test environment... this may take some time", :reset => true)
      require 'test/test_helper'
      require 'test/unit/ui/console/testrunner'

#      @runner = Runner.new(options)
    end

    def start
      ::Guard::UI.info("Guard::Reloader #{ReloaderVersion::VERSION} is running, with Test::Unit #{::Test::Unit::VERSION}!", :reset => true)
      run_all if @options[:all_on_start]
    end

    #taken from rails source code ==> http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-camelize
    def camelize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    def get_model_name(p)
      m = %r{^app/models/(.+)\.rb$}.match(p)
      camelize(m[1]) if m[1]
    end
    def get_controller_name(p)
      m = %r{^app/controllers/(.+)\.rb$}.match(p)
      camelize(m[1]) if m[1]
    end
    def get_unit_test_path(p)
      m = %r{^app/models/(.+)\.rb$}.match(p)
      "test/unit/#{m[1]}_test.rb"
    end
    def get_functional_test_path(p)
      m = %r{^app/controllers/(.+)\.rb$}.match(p)
      "test/functional/#{m[1]}_test.rb"
    end
    def get_test_name(p)
      m = %r{^test/(unit|functional)/(.+)\.rb$}.match(p)
      if m[2]
        camelize(m[2])
      end
    end
    def unit_test?(p)
      !!%r{^test/unit/(.+)\.rb$}.match(p)
    end
    def functional_test?(p)
      !!%r{^test/functional/(.+)\.rb$}.match(p)
    end
    def controller?(p)
      !!%r{^app/controllers/(.+)\.rb$}.match(p)
    end
    def model?(p)
      !!%r{^app/models/(.+)\.rb$}.match(p)
    end
    def json?(p)
      begin
        map = JSON.parse(p)
        !!map["path"]
      rescue
        false
      end
    end
    def smart_test(path)
      if model?(path)
        ::Guard::UI.info("Detected #{path} as model!", :reset => true)
        model_class = reload(get_model_name(path), path)
        test_path = get_unit_test_path(path)
        test_class = reload(get_test_name(test_path),test_path)
        execute_test(test_class) if test_class
      elsif controller?(path)
        ::Guard::UI.info("Detected #{path} as controller!", :reset => true)
        controller_class = reload(get_controller_name(path), path)
        test_path = get_functional_test_path(path)
        test_class = reload(get_test_name(test_path),test_path)
        execute_test(test_class) if test_class
      elsif unit_test?(path)
        ::Guard::UI.info("Detected #{path} as unit test!", :reset => true)
        test_class = reload(get_test_name(path),path)
        execute_test(test_class) if test_class
      elsif functional_test?(path)
        ::Guard::UI.info("Detected #{path} as functional test!", :reset => true)
        test_class = reload(get_test_name(path),path)
        execute_test(test_class) if test_class
      else
        ::Guard::UI.info("Give up on #{path}", :reset => true)
      end
      ::Guard::UI.info("Process for #{path} is done!\n\n", :reset => true)
    end
    def run_on_change(paths)
     paths.each {|p| smart_test(p) }
#      paths  = Inspector.clean(paths)
#      passed = @runner.run(paths)
    end
    def execute_test(klass)
      begin
        ::Guard::UI.info("run test for #{klass.name}")
        Test::Unit::UI::Console::TestRunner.run(klass) if klass
#        rescue Exception => ex find what kind of exception to handle first
      end
    end
    def to_class(class_name)
      begin
        k = class_name.split('::').inject(Object) {|p, x| p.const_get(x.to_sym) }
      rescue NameError => ex
        puts "#{class_name} class doesn't exists"
      end
    end
    def class_symbol(class_name)
      class_name.split('::')[-1].to_sym
    end
    def reload(klass_name, path)
      begin
        klass = to_class(klass_name)
        if klass
          ::Guard::UI.info("Killing #{klass_name} class", :reset => true)
          klass.parent.send(:remove_const, class_symbol(klass_name))
        end
        load(path)
        ::Guard::UI.info("#{klass_name} on #{path} reloader process is done!", :reset => true)
        to_class(klass_name)
      rescue Exception => ex
        puts ex
      end
    end

  end
end
