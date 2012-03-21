
require 'spec_helper'

describe RootsController do
  let(:buckets) { Array.new }

  describe 'GET show' do
    context 'not authorized' do
      before do
        session[:access_token] = nil
        get :show
      end
      it { response.should be_success }
      it { assigns[:authorized].should be_false }
      it { assigns[:queued].should be_false }
    end
    context 'authorized' do
      before do
        session[:access_token] = 'access_token'
        session[:user_profile] = { :twitter_id => '1234', :twitter_screen_name => 'cohakim' }
        get :show
      end
      it { response.should be_success }
      it { assigns[:authorized].should be_true }
      it { assigns[:queued].should be_false }
    end
    context 'queued' do
      let(:processing) { FactoryGirl.create(:processing, :serial => '1234') }
      before do
        session[:access_token] = 'access_token'
        session[:user_profile] = { :twitter_id => '1234', :twitter_screen_name => 'cohakim' }
        buckets << processing
        get :show
      end
      it { response.should be_success }
      it { assigns[:authorized].should be_true }
      it { assigns[:queued].should be_true }
    end
  end

  describe 'GET oauth_callback' do
    context 'not accepted' do
      before do
        get :oauth_callback, :oauth_token => nil, :oauth_verifier => nil
      end
      it { response.should be_redirect }
    end
    context 'accepted' do
      before do
        controller.stub(:set_twitter_access_token).and_return(true)
        get :oauth_callback, :oauth_token => 'oauth_token', :oauth_verifier => 'oauth_verifier'
      end
      it { response.should be_redirect }
    end
  end

  context 'DELETE logout' do
    before do
      get :logout
    end
    it { response.should be_redirect }
  end

  describe 'POST clean' do
    pending
  end

  describe 'POST abort' do
    pending
  end

  describe 'GET status' do
    pending
  end
end