require 'sinatra/base'
require 'faye'
require 'erb'

module VetCI
  class Server < Sinatra::Base
    
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
    post '/:project/build' do
      project = Project.named(params[:project])
      project.build(env['faye.client'], params[:payload]) unless project.nil?
      status 200
    end
    
    # DELETES a project's build
    #get '/:project/builds/:build_id/destroy' do
    #  redirect "/#{params[:project]}"
    #end
    
    #Renders the project's details page.
    get '/:project' do
      @project = Project.named(params[:project])
      pass if @project.nil?
      @builds = @project.pagedBuilds(params[:page], 5)
      erb :project
    end
    
    post '/command/build_all' do
      Project.projects.each do |name, project|
        project.build(env['faye.client'])
      end
      status 200
    end
    
    get '/' do
      @projects = Project.projects
      erb :index
    end
    
    def self.start
      VetCI::Server.run! :host => '0.0.0.0', :port => 4567
    end
  end
end