
#guard 'test' do
#  watch(%r{^lib/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
#  watch(%r{^test/.+_test\.rb$})
#  watch('test/test_helper.rb')  { "test" }

  # Rails example
#  watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
#  watch(%r{^app/controllers/(.+)\.rb$})              { |m| "test/functional/#{m[1]}_test.rb" }
#  watch(%r{^app/views/.+\.rb$})                      { "test/integration" }
#  watch('app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
#end

guard 'idos' do
  watch(%r{^app/models/(.+)\.rb$})     { |m| "path,#{m[0]};klass,#{m[1]};test_path,test/unit/#{m[1]}_test.rb;test_klass,#{m[1]}_test;context,bango" }
  watch(%r{^test/unit/(.+)\.rb$}) { |m| "path,#{m[0]};klass,#{m[1]};test_path,#{m[0]};test_klass,#{m[1]};context,bango" }
end