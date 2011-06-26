# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name          = 'rack-cache-control'
  s.version       = '0.0.1'
  s.summary       = 'Set the Cache-Control response header.'

  s.author        = 'John Labovitz'
  s.email         = 'johnl@johnlabovitz.com'
  s.description   = %q{
    Set the Cache-Control response header.
    
    Note that this was not written by me, but rather by Geoff Buesing.  See README for details.
  }
  s.homepage      = 'http://github.com/jslabovitz/rack-cache-control'

  s.add_development_dependency 'test-spec'
  
  s.files        = Dir.glob('{bin,lib,test}/**/*') + %w(README.textile)
  s.require_path = 'lib'
end