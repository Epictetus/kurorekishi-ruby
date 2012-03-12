Kurorekishi::Application.routes.draw do
  # root
  resource :roots, :only => [:show]
  match 'help' => 'roots#help', :path => 'help', :as => 'help'
  match 'oauth_callback' => 'roots#oauth_callback', :path => 'oauth_callback', :as => 'oauth_callback'
  match 'clean' => 'roots#clean', :path => 'clean', :as => 'clean'
  match 'stats' => 'roots#stats', :path => 'stats', :as => 'stats'
  match 'reset_session' => 'roots#destroy_session', :path => 'reset_session', :as => 'reset_session'

  root :to => "roots#show"

  # resque
  mount Resque::Server.new, :at => "/resque"
end
