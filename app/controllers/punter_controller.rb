class PunterController < ApplicationController
  include PunterSystem

  before_filter :login_required, :only => [ :show, :edit, :update ]
  before_filter :admin_required, :only => [ :reject ]
  verify :params => :punter, :only => [ :update ], :redirect_to => :user_show_path


  def login
    session[:punter_id] = nil

    return if request.get? # login form
    unless params.has_key?(:punter) && params[:punter].has_key?(:email) && params[:punter].has_key?(:password)
      flash[:notice] = 'Incorrect details entered. Please try again.'
      return
    end
    begin
      punter = Punter.authenticate_by_password(params[:punter][:email], params[:punter][:password])
    rescue RuntimeError
      flash[:notice] = 'Incorrect details entered. Please try again.'
      return
    end

    session[:punter_id] = punter.id
    if session[:after_login]
      redirect_to(session[:after_login])
    else
      redirect_to user_show_path
    end
  end

  def logout
    session[:punter_id ] = nil
    flash[:notice] = 'You have logged out.'
    redirect_to login_path
  end

  def confirm
    session[:punter_id ] = nil
    unless params.has_key?(:token)
      # FIXME: doubt this can happen, no routing
      flash[:notice] = 'Incorrect user confirmation details.'
      redirect_to login_path
    end

    begin
      punter = Punter.authenticate_by_token(params[:token])
    rescue
      flash[:notice] = 'Incorrect user confirmation details.'
      redirect_to login_path
      return
    end

    punter.confirm!
    
    session[:punter_id] = punter.id
    redirect_to user_edit_path
  end

  def edit
  end

  def reset
  end

  def reject
    render :show
  end

  def show
  end

  def update
    params[:punter].delete(:admin)
    if @punter.update_attributes(params[:punter])
      flash[:notice] = 'Details updated.'
      redirect_to user_show_path
    else
      render :edit
    end
  end

end

