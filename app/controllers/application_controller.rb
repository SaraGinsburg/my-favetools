require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'

    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']

    register Sinatra::Flash
  end #-- configure --

  before do
    pass if (request.path_info == "/" ||
            request.path_info == "/login" ||
            request.path_info == "/logout" ||
            request.path_info == "/signup")

    if !logged_in?
      flash[:message] = "Please log in or sign up first before you can use myFaveTools"
      redirect :"/"
    end
  end #-- before --

  # GET / route #index action
  # Home page for user registration, if not logged in or
  # index page to display all public items
  get "/" do
    if logged_in?
      redirect :"/users/#{current_user.slug}/folders"
    else
      erb :index
    end
  end #-- get / --

  # handle 404 errors
  not_found do
    if logged_in?
      erb :'not_found'
    else
      flash[:message] = "You need to be logged in"
      redirect :'/login'
    end
  end #-- not_found --

  helpers do

    def logged_in?
      #!!current_user
      !!session[:user_id]
    end

    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
      # User.find(session[:user_id])
    end

    def reset_current_user
      @current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def set_session
      session[:user_id] = @user.id
    end

    def logout
      # reset @current_user
      remove_instance_variable(@current_user) if @current_user
      session.clear
    end

    def path_info
      request.path_info
    end
  end #-- helpers --
end
