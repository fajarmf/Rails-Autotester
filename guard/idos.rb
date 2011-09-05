# encoding: utf-8
require 'guard'
require 'guard/guard'
require 'guard/idos/version'
require 'test/unit/version'

module Guard
  class Idos < Guard

    def initialize(watchers=[], options={})
      super
      @options = {
        :all_on_start   => true,
        :all_after_pass => true,
        :keep_failed    => true
      }.update(options)
      ::Guard::UI.info("Guard::Idos #{IdosVersion::VERSION} setting up test environment... this may take some time", :reset => true)
      require 'test/test_helper'
      require 'test/unit/ui/console/testrunner'

#      @runner = Runner.new(options)
    end

    def start
      ::Guard::UI.info("Guard::Idos #{IdosVersion::VERSION} is running, with Test::Unit #{::Test::Unit::VERSION}!", :reset => true)
      run_all if @options[:all_on_start]
    end

    def generate_options(paths)
      paths.collect do |path|
        if path.include?(';')
          options = {}
          path.split(';').each do |item|
            tmp = item.split(',')
            if tmp.size > 1
              options.update({tmp[0].to_sym => tmp[1..(tmp.size-1)]})
            end
          end
          options
        else
          path
        end
      end      
    end

    def camelize(str)
      str.split('_').collect{|s|s.capitalize}.join #should see how to implement camelize correctly
    end
    def run_on_change(paths)
      puts "Detect changes on #{paths.inspect}"
      options = generate_options(paths)
      options.each do |option|
        puts "Now working on option -> #{option.inspect}"
        klass = camelize(option[:klass][0])
        path = option[:path][0]
        test_klass = camelize(option[:test_klass][0])
        test_path = option[:test_path][0]
        reload(klass, path)
        reload(test_klass, test_path) unless testfile?(path)
        ::Guard::UI.info("run test for #{test_klass.to_sym}")
        runtest(test_klass.to_sym)
        puts "-------"
      end
#      paths  = Inspector.clean(paths)
#      passed = @runner.run(paths)
    end
    def runtest(klass_sym)
      begin
        if Object.const_defined?(klass_sym)
          klass = Object.const_get(klass_sym)
          Test::Unit::UI::Console::TestRunner.run(klass)
        end
#        rescue Exception => ex find what kind of exception to handle first
      end
    end
    def reload(klass, path)
      puts "reload #{klass}, #{path}"
      begin
        if Object.const_defined?(klass.to_sym)
          puts "removing #{klass} definition"
          test_class = Object.const_get(klass.to_sym)
          tests = test_class.instance_methods.select {|m| /^test_/.match(m)}
          tests.each {|t| test_class.send(:remove_method, t.to_sym)}
          Object.send(:remove_const, klass.to_sym)
        end
        puts "loading the new file #{path}"
        load(path)
        puts "done reloading #{klass}, #{path}"
      rescue Exception => ex
        puts ex
      end

    end
    def testfile?(path)
      !!/^test\//.match(path)
    end

  end
end
