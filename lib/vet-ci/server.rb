require 'sinatra/base'
require 'faye'
require 'erb'

module VetCI
  class Server < Sinatra::Base
    attr_accessor :core
    
    lib_dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{lib_dir}/views"
    set :public, "#{lib_dir}/public"
    set :static, true

    use Faye::RackAdapter, :mount => '/faye',
                           :timeout => 25
                           
    

    helpers do 
      # Thanks CI-Joe, and Integrity by association.
      def ansi_color_codes(string)
        string.gsub("\e[0m", '</span>').
          gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
      end
    end

    get '/api/:project' do
      # If you ping this URL, you'll trigger the
      # Build action for this particular one.
      @core.projects[params[:project]].build
      env['faye.client'].publish('/all', 'text' => 'hello world')
      env['faye.client'].publish("/project/#{params[:project]}", 'text' => 'hello world')
      status 200
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