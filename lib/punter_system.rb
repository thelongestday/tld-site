require 'punter_exception'

module PunterSystem

  protected

  def login_required
    begin
      unless session[:punter_id]
        logger.error("PunterSystem: no punter_id in session")
        raise PunterException, "no cookie!"
      end
      @punter = Punter.find(session[:punter_id])
      unless @punter
        logger.error("PunterSystem: couldn't find Punter id #{session[:punter_id]}")
        raise PunterException, "unfound punter"
      end
      logger.info("PunterSystem: [#{@punter.id}] #{@punter.name_with_email}")
      logger.info("UA: #{request.env['HTTP_USER_AGENT']}")
    rescue PunterException
      flash[:error] = "Please login."
      return_here_after_login
      redirect_to login_path
    end

    enforce_signup

  end

  def admin_required
    begin
      raise PunterException unless session[:punter_id]
      punter = Punter.find(session[:punter_id])
      raise PunterException unless punter
      raise PunterException unless punter.admin?
      @punter = punter
      logger.info("PunterSystem: [admin] #{@punter.name_with_email}")
    rescue PunterException
      flash[:error] = "Please login."
      return_here_after_login
      redirect_to login_path
    end
  end

  def page_filter
    if params[:index] == 'invitees'
      login_required
    elsif params[:index] == 'attendees'
      login_required
      return unless @punter

      unless @punter.has_paid_ticket?
        flash[:notice] = 'You need to buy a ticket to see that page.'
        redirect_to user_show_path
        return
      end
    else
      begin
        @punter = Punter.find(session[:punter_id])
      rescue
      end
      true
    end

    enforce_signup

  end

  def enforce_signup
    if @punter && @punter.has_flailed_signup?
      logger.debug('flail')
      unless [ user_edit_path, user_update_path ].include? request.path
        logger.debug('more flail')
        flash[:notice] = 'Please update your details.'
        logger.info("PunterSystem: punting #{@punter.name_with_email} back to edit page")
        redirect_to user_edit_path
        return
      end
    else
      logger.debug('no flail')
    end
  end

  def return_here_after_login
    session[:after_login] = request.request_uri
  end

end

