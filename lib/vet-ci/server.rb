require 'sinatra/base'
require 'erb'

module VetCI
  class Server < Sinatra::Base
    attr_accessor :core
    
    lib_dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{lib_dir}/views"
    set :public, "#{lib_dir}/public"
    set :static, true

    get '/api/:project' do
      # If you ping this URL, you'll trigger the
      # Build action for this particular one.
      @core.projects[params[:project]].build
    end
    
    get '/:project' do
      @cur_project = @core.projects[params[:project]]
      pass if @cur_project.nil?
      erb :project
    end
    
    get '/' do
      @projects = @core.projects
      erb :index
    end
    
    def initialize(*args)
      super
      @core = options.core_obj
    end
    
    def self.start(core)
      set :core_obj, core
      VetCI::Server.run! :host => '0.0.0.0', :port => 4567
    end
  end
end