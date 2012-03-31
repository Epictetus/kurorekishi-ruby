Kurorekishi::Application.routes.draw do
  # root
  resource :roots, :only => [:show]
  match 'help' => 'roots#help', :path => 'help', :as => 'help'
  match 'media' => 'roots#media', :path => 'media', :as => 'media'
  match 'oauth_callback' => 'roots#oauth_callback', :path => 'oauth_callback', :as => 'oauth_callback'
  match 'clean' => 'roots#clean', :path => 'clean', :as => 'clean'
  match 'abort' => 'roots#abort', :path => 'abort', :as => 'abort'
  match 'stats' => 'roots#stats', :path => 'stats', :as => 'stats'
  match 'logout' => 'roots#logout', :path => 'logout', :as => 'logout'
  match 'notification' => 'roots#notification', :path => 'notification', :as => 'notification'

  root :to => "roots#show"
end
