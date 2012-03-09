Kurorekishi::Application.routes.draw do
  # root
  resource :roots, :only => [:show]
  match 'oauth_callback' => 'roots#oauth_callback', :path => 'oauth_callback', :as => 'oauth_callback'
  match  'stats' => 'roots#stats', :path => 'stats', :as => 'stats'
  post 'clean' => 'roots#clean', :path => 'clean', :as => 'clean'

  root :to => "roots#show"
end
