require 'sinatra/base'
require 'erb'

module VetCI
  class Server < Sinatra::Base
    @core = nil
    
    lib_dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{lib_dir}/views"
    set :public, "#{lib_dir}/public"
    set :static, true
    
    get '/' do
      erb :index, :locals => {:projects => @core.projects }
    end
    
    get '/api/:project' do
      # If you ping this URL, you'll trigger the
      # Build action for this particular one.
    end
    
    def self.start(core)
      @core = core
      VetCI::Server.run! :host => '0.0.0.0', :port => 4567
    end
  end
end