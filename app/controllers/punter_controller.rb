class PunterController < ApplicationController
  include PunterSystem
  layout 'tld'

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
    rescue PunterException
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
      flash[:error] = 'Incorrect user confirmation details.'
      redirect_to login_path
    end

    begin
      punter = Punter.authenticate_by_token(params[:token])
    rescue
      flash[:error] = 'Incorrect user confirmation details.'
      redirect_to login_path
      return
    end

    punter.confirm!
    
    session[:punter_id] = punter.id
    flash[:notice] = "Please now set yourself a password"

    redirect_to user_edit_path
  end

  def edit
    @must_set_password = @punter.salted_password.empty?
  end

  def reset
    return if request.get? # reset form
    unless params[:punter] && params[:punter][:email] && !params[:punter][:email].empty?
      flash[:error] = 'Incorrect details entered. Please try again.'
      return
    end
    if punter = Punter.find_by_email(params[:punter][:email])
      punter.reset!
      flash[:notice] = "We've resent an invite link to this address. Please check your mail."
      redirect_to login_path
      return
    else
      flash[:error] = "We don't have anyone registered with that address, sorry."
    end
  end

  def reject
    render :show
  end

  def show
  end

  def update
    params[:punter].delete(:admin)
    params[:punter].delete(:email)

    if @punter.salted_password.empty?
      @punter.set_new_password = true
    end

    if @punter.update_attributes(params[:punter])
      flash[:notice] = 'Details updated.'
      redirect_to user_show_path
    else
      render :edit
    end
  end


end

