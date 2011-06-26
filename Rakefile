task :test do
  ruby 'test/spec_rack_cache_control.rb'
end
 
task :build => :test do
  system 'gem build rack-cache-control.gemspec'
end

task :release => :build do
  system "gem push rack-cache-control-#{Rack::CacheControl::VERSION}"
end