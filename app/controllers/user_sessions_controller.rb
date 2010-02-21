class UserSessionsController < ApplicationController

  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to '/'
    else
      flash[:error] = t('user_sessions.create.error')
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = t('user_sessions.destroy.notice')
    redirect_to login_path
  end
end