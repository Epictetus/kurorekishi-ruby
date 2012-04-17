Kurorekishi::Application.routes.draw do
  # root
  scope :module => 'roots' do
    get :show, :path => 'show', :as => 'show'
    get :help, :path => 'help', :as => 'help'
    get :media, :path => 'media', :as => 'media'
  end

  # root
  resource  :cleaner
  resources :cleaners, :only => [:index]


  # sessions
  scope :module => 'sessions' do
    get :new,     :path => 'twitter/authorize_url', :as => 'authorize_url_twitter'
    get :create,  :path => '/login',  :as => 'login'
    get :destroy, :path => '/logout', :as => 'logout'
  end

  root :to => "roots#show"
end
