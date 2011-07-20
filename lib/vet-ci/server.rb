require 'sinatra/base'
require 'faye'
require 'erb'
require 'vet-ci/project'

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
    
    # Triggers that a project should be built
    get '/:project/build' do
      Project.first(:name => params[:project]).build(env['faye.client'])
      status 200
    end
    
    # DELETES a project's build
    get '/:project/builds/:build_id/destroy' do
      Project.first(:name => params[:project]).builds.get(params[:build_id]).destroy
      redirect "/#{params[:project]}"
    end
    
    #Renders the project's details page.
    get '/:project' do
      @project = Project.first(:name => params[:project])
      pass if @project.nil?
      erb :project
    end
    
    post '/command/build_all' do
      Project.all.each do |project|
        project.build(env['faye.client'])
      end
      status 200
    end
    
    get '/' do
      @projects = Project.all
      erb :index
    end
    
    def self.start
      VetCI::Server.run! :host => '0.0.0.0', :port => 4567
    end
  end
end