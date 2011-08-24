require 'find'
require 'digest/md5'

class Checker
  def initialize(root='.')
    @root = root
    @file_hash = Hash.new
  end

  def file_hash
    @file_hash
  end

  def diff
    @diff.sort || []
  end

  def doit
    @diff = []
    Find.find('.') do |file|
      next if /\.(svn|gitignore|project|swp)/.match(file.sub("#{@root}/",""))
      next unless File.file?(file)
      begin
        newhash = Digest::MD5.hexdigest(File.read(file))
        unless newhash == @file_hash[file]
          if @file_hash[file]
            puts "CHANGED #{file}"
          else
            puts "ADDED #{file}"
          end
        @file_hash[file] = newhash
        @diff << file
        end
      rescue
        puts "Error reading #{file} --- MD5 hash not computed."
      end
    end
  end
end

class Autotester
  def initialize(checker=nil)
    load 'test/test_helper.rb'
    require 'test/unit/ui/console/testrunner'
    @checker = checker || Checker.new('.')
    @checker.doit
  end

  def coba testcase
    Test::Unit::UI::Console::TestRunner.run testcase if testcase
  end

  def reload testcase,f
    arr = testcase.instance_methods.select {|x| /test: /.match(x)}
    arr.each {|m| testcase.send :remove_method, m.to_sym }
    load f
  end

  def doit
    while 1 do
      @checker.doit()
      unless @checker.diff.empty?
        @checker.diff.each do |f|
          next unless /\.rb$/.match(f)
          load f
          classname = f.split('/').last.sub('.rb','').camelize
          classname = "New::" + classname if /\/new\//.match(f)
          testcase = nil
          if /app/.match(f)
            puts "loading new code #{f}"
            load f
            testcase = eval("#{classname}Test")
          elsif /test/.match(f)
            puts "running updated test case #{f}"
            testcase = eval(classname)
            reload testcase,f
          end
          coba testcase
        end
      end
    end
  end
end

$tester = Autotester.new
$input = ''
while $input != 'q' && $input != 'Q'
  puts 'watching the files now, will run the test after you save the changes'
  begin
  $tester.doit()
  rescue
    puts "Uh sorry! We encounter some problem, press 'q' to quit otherwise you can just press anykey to continue testing."
    $input = STDIN.gets
  end
end