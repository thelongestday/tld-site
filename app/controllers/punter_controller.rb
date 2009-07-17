class PunterController < ApplicationController
  include PunterSystem
  layout 'tld_app'

  before_filter :login_required, :only => [ :edit, :invite, :show, :update ]
  before_filter :admin_required, :only => [ :reject ]
  verify :params => :punter, :only => [ :update ], :redirect_to => :user_show_path
  verify :params => :invitee, :only => [ :invite ], :redirect_to => :user_show_path

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
      session[:after_login] = nil
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
      @punter = Punter.authenticate_by_token(params[:token])
      logger.info("PunterController: #{@punter.name_with_email} confirmed")
    rescue PunterException
      # flash[:error] = 'Incorrect user confirmation details.'
      redirect_to '/'
      return
    end

    # argh - we don't have a name at the moment, so AASM transition fails
    # keep it in since we test for it
    @punter.confirm!
    # fake the transition
    @punter.update_attribute(:state, 'confirmed') # ouch
    
    session[:punter_id] = @punter.id
    flash[:notice] = "Thanks for signing up! Please now check your details and choose a password. If you don't do this you'll be unable to log in - doh!"

    @must_set_password = true
    @punter = Punter.find(@punter)
    render :action => :edit
  end

  def confirm_frame
    render :layout => 'tld_frame'
  end

  def edit
    @must_set_password = @punter.salted_password.empty?
  end

  def invite
    redirect_to user_show_path if request.get?

    @invitee = Punter.new(params[:invitee])
    @invitee.non_unique_email = true # allow people to be re-invited by someone-else

    if @invitee.valid?
      begin
        Invitation.invite_punter(@punter, @invitee.email, @invitee.name)
        flash[:notice] = "OK, #{@invitee.name_with_email} invited!"
      rescue PunterException => e
        flash[:error] = e.message
      end
      redirect_to orders_path
      return
    else
      render :show
    end
  end

  def invite_self
    redirect_to user_show_path if request.get?

    if Punter.find_by_email(params[:invitee][:email])
      flash[:notice] = "You've already signed up. Reset your password below, or use the Login link."
      redirect_to user_reset_path
      return
    end

    @invitee = Punter.new(params[:invitee])

    if @invitee.valid?
      begin
        Invitation.invite_punter(Site::Config.signup_user, @invitee.email, @invitee.name)
        flash[:notice] = "Signup under way!"
      rescue PunterException => e
        flash[:error] = e.message
      end

      redirect_to signup_ack_path
      return
    else
      render :signup
    end
  end


  def reset
    return if request.get? # reset form
    unless params[:punter] && params[:punter][:email] && !params[:punter][:email].empty?
      flash[:error] = 'Incorrect details entered. Please try again.'
      return
    end
    if punter = Punter.find_by_email(params[:punter][:email])
      punter.reset!
      logger.info("PunterController: reset for #{punter.name_with_email} with token #{punter.authentication_token}")
      flash[:notice] = "We've sent an password reset mail to #{punter.email}. Please check your mail."
      redirect_to login_path
      return
    else
      flash[:error] = "We don't have anyone registered with that address, sorry."
    end
  end

  def reject
    render :show
  end

  def signup
  end

  def signup_ack
  end

  def show
    @invitee = Punter.new
  end

  def update
    redirect_to user_show_path if request.get?

    params[:punter].delete(:email)

    if @punter.salted_password.empty?
      @punter.set_new_password = true
    end

    if params[:punter].has_key?(:password) &&
       params[:punter].has_key?(:password_confirmation) 
      if params[:punter][:password].empty?
        params[:punter].delete(:password)
        params[:punter].delete(:password_confirmation)
      else
        @punter.set_new_password = true
      end
    end

    if params[:punter].keys.empty?
      # nothing left to do
      redirect_to user_show_path
      return
    end

    if @punter.update_attributes(params[:punter])
      flash[:notice] = 'Details updated.'
      @punter.clear_token
      redirect_to user_show_path
    else
      @must_set_password = @punter.salted_password.empty?
      render :edit
    end
  end


end

