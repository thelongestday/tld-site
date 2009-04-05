class PunterController < ApplicationController
  def login
    session[:punter_id] = nil

    return if request.get? # login form
    unless params.has_key?(:punter) && params[:punter].has_key?(:email) && params[:punter].has_key?(:password)
      flash[:notice] = 'Incorrect details entered. Please try again.'
      return
    end
    begin
      punter = Punter.authenticate_by_email(params[:punter][:email], params[:punter][:password])
    rescue
      flash[:notice] = 'Incorrect details entered. Please try again.'
      return
    end

    session[:punter_id] = punter.id
    redirect_to user_show_path
  end

  def logout
    session[:punter_id ] = nil
    flash[:notice] = 'You have logged out.'
    redirect_to login_path
  end

  def confirm
    session[:punter_id ] = nil
    unless params.has_key?(:email) && params.has_key?(:token)
      # FIXME: doubt this can happen, no routing
      flash[:notice] = 'Incorrect user confirmation details.'
      redirect_to login_path
    end

    begin
      punter = Punter.authenticate_by_token(params[:email], params[:token])
    rescue
      flash[:notice] = 'Incorrect user confirmation details.'
      redirect_to login_path
      return
    end

    session[:punter_id] = punter.id
    redirect_to user_show_path
  end

  def edit
  end

  def reset
  end

  def show
  end

end
