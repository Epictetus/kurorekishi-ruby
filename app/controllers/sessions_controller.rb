# -*- encoding: utf-8 -*-

class SessionsController < ApplicationController
  include ::TwitterController::TwitterModule

  def new
    set_twitter_authorize_url

    respond_to do |format|
      format.json { render :json => { :authorize_url => @authorize_url } }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    respond_to do |format|
      format.json { render :nothing => true, :status => 503 }
    end

  end

  def create
    if authentication_accepted?
      set_twitter_access_token
    end

    respond_to do |format|
      format.html { redirect_to root_url }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver
    flash[:notice] = 'Twitter認証に失敗しました。（◞‸◟）'

    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  def destroy
    reset_session
    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  ############################################################################
  protected

  def authentication_accepted?
    (params[:oauth_token].present? && params[:oauth_verifier].present?)
  end

end
