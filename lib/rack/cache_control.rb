require 'rack'

module Rack
  class CacheControl
        
    # Lets you set the Cache-Control response header from middleware. Does not overwrite
    # existing Cache-Control response header, if it already has been set.
    #
    # Examples:
    #
    #   use Rack::CacheControl, :public, :max_age => 5
    #     # => Cache-Control: public, max-age=5
    #
    #   use Rack::CacheControl, :private, :must_revalidate, :community => "UCI"
    #     # => Cache-Control: private, must-revalidate, community="UCI"
    #
    # Values specified as a Proc will be called at runtime for each request:
    #
    #   use Rack::CacheControl, :public, :max_age => Proc.new { rand(6) + 3 }
    #     # => Cache-Control: public, max-age=5
    def initialize(app, *directives)
      @app = app
      @hash = extract_hash!(directives)
      @directives = directives
      extract_non_callable_values_from_hash!
      stringify_hash_keys!
      stringify_directives!
    end

    def call(env)
      response = @app.call(env)
      headers = Utils::HeaderHash.new(response[1])
      unless headers.has_key?('Cache-Control')
        headers['Cache-Control'] = directives
      end
      response[1] = headers
      response
    end
    
    private
      def extract_hash!(array)
        array.last.kind_of?(Hash) ? array.pop : {}
      end
      
      def extract_non_callable_values_from_hash!
        @hash.reject! { |k,v| v == false }
        @hash.reject! { |k,v| @directives << k if v == true }
        @hash.reject! { |k,v| @directives << "#{k}=#{v.inspect}" if !v.respond_to?(:call) }
      end
      
      def stringify_hash_keys!
        @hash = Hash[
          @hash.map do |key, value|
            [stringify_directive(key), value]
          end
        ]
      end
      
      def stringify_directives!
        @directives = @directives.map {|d| stringify_directive(d)}.join(', ')
      end
      
      def stringify_directive(directive)
        directive.to_s.tr('_','-')
      end
      
      def directives
        @hash.inject(@directives) {|str, (k, v)| "#{str}, #{k}=#{v.call.inspect}"}
      end
  end
end