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
    rescue PunterException
      flash[:error] = "Please login."
      return_here_after_login
      redirect_to login_path
    end
  end

  def admin_required
    begin
      raise PunterException unless session[:punter_id]
      punter = Punter.find(session[:punter_id])
      raise PunterException unless punter
      raise PunterException unless punter.admin?
      @punter = punter
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
  end

  def return_here_after_login
    session[:after_login] = request.request_uri
  end

end

