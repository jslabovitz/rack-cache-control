lib = File.expand_path('../../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

gem 'test-unit'

require 'test/spec'
require 'rack/mock'
require 'rack/cache_control'

context "Rack::CacheControl" do

  setup do
    @app = Proc.new { [200, {}, []]}
  end

  specify "integer value for key=value directive" do
    middleware = Rack::CacheControl.new(@app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == 'public, max-age=5'
  end
  
  specify "string value for key=value directive" do
    middleware = Rack::CacheControl.new(@app, :public, :community => "UCI")
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == %(public, community="UCI")
  end

  specify "proc value for key=value directive" do
    value = 7 #compile-time value
    middleware = Rack::CacheControl.new(@app, :public, :max_age => Proc.new {value})
    value = 5 #runtime value
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should ==  'public, max-age=5'
  end
  
  specify "multiple directives" do
    middleware = Rack::CacheControl.new(@app, :private, :no_cache, :must_revalidate)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == %(private, no-cache, must-revalidate)
  end
  
  specify "true value" do
    middleware = Rack::CacheControl.new(@app, :private, :must_revalidate => true)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == 'private, must-revalidate'
  end
  
  specify "false value" do
    middleware = Rack::CacheControl.new(@app, :private, :must_revalidate => false)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == 'private'
  end

  specify "respects existing Cache-Control header" do
    app = Proc.new { [200, {'Cache-Control' => 'private'}, []]}
    middleware = Rack::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == 'private'
  end

  specify "respects existing Cache-Control header with case-insensitivity" do
    app = Proc.new { [200, {'cache-control' => 'private'}, []]}
    middleware = Rack::CacheControl.new(app, :public, :max_age => 5)
    status, headers, body = middleware.call({})
    headers['Cache-Control'].should == 'private'
  end

end