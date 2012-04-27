# -*- encoding: utf-8 -*-

class CleanersController < ApplicationController
  include ::TwitterController::TwitterModule

  ############################################################################

  before_filter :authorized_required, :except => [:index]
  before_filter :queued_required, :only => [:show, :destroy]

  def authorized_required
    redirect_to(root_path) unless authorized?
  end

  def queued_required
    redirect_to(new_cleaner_path) unless queued?
  end

  ############################################################################

  def index
    @cleaners = {
      :destroy_count => Stats.fetch[:destroy_count],
      :users_count   => Stats.fetch[:users_count],
      :target_count  => Bucket.count_job,
      :busyness      => Bucket.busyness,
    }

    respond_to do |format|
      format.json { render :json => @cleaners }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    @cleaners = {
      :destroy_count => '---',
      :users_count   => '---',
      :target_count  => '---',
      :busyness      => '---',
    }

    respond_to do |format|
      format.json { render :json => @cleaners }
    end

  end

  def show
    set_user_profile
    twitter = twitter_from_session

    begin
      rate_limit_status = twitter.rate_limit_status['remaining_hits']
    rescue
      rate_limit_status = '---'
    end

    job = Bucket.find_by_serial(@user_profile[:twitter_id]) || (raise StandardError)
    @stats = {
      :destroy_count  => job.destroy_count,
      :remaining_hits => rate_limit_status,
      :elapsed_time   => job.elapsed_time,
      :page           => job.page,
      :auth_failed_count => job.auth_failed_count,
      :busyness       => Bucket.busyness,
    }

    respond_to do |format|
      format.html
      format.json { render :json => @stats }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    @stats = {
      :destroy_count  => '---',
      :remaining_hits => '---',
      :elapsed_time   => '---',
      :page           => '---',
      :auth_failed_count => '---',
      :busyness       => '---',
    }

    respond_to do |format|
      format.html
      format.json { render :noting => true, :status => 503 }
    end

  end

  ############################################################################

  def new
    set_user_profile
    if queued? then redirect_to(cleaner_path); return end

    respond_to do |format|
      format.html
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    reset_session
    flash[:notice] = 'Twitterが混雑しているようです。ログインをやり直してください。'

    respond_to do |format|
      format.html { redirect_to root_path }
    end

  end

  def create
    set_user_profile

    cleaner = Bucket.find_by_serial(@user_profile[:twitter_id])
    if cleaner.blank?
      Bucket.create!({
        :serial => @user_profile[:twitter_id],
        :token  => @user_profile[:access_token],
        :secret => @user_profile[:access_token_secret],
        :auth_failed_count => 0,
      })
    end

    respond_to do |format|
      format.html { redirect_to cleaner_path }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    reset_session
    flash[:notice] = '削除を開始できませんでした。'

    respond_to do |format|
      format.html { redirect_to root_path }
    end

  end

  ############################################################################

  def destroy
    set_user_profile

    job = Bucket.find_by_serial(@user_profile[:twitter_id])
    job.try(:destroy)

    reset_session

    respond_to do |format|
      format.html { redirect_to root_path }
    end

  rescue => ex
    ExceptionNotifier::Notifier.exception_notification(request.env, ex).deliver

    reset_session
    flash[:notice] = '削除処理を完了できなかったかもしれません。ログインして確認してください。'

    respond_to do |format|
      format.html { redirect_to root_path }
    end

  end

end
