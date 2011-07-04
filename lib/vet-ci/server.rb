require 'sinatra/base'
require 'erb'

module VetCI
  class Server < Sinatra::Base
    lib_dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{lib_dir}/views"
    set :public, "#{lib_dir}/public"
    set :static, true
    
    get '/' do
      "Hello World"
    end
    
    def self.start
      VetCI::Server.run! :host => '0.0.0.0', :port => 4567
    end
  end
end