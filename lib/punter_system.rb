module PunterSystem

  def login_required
    if session[:punter_id] && Punter.find(session[:punter_id])
      return
    else
      flash[:error] = "Please login."
      return_here_after_login
      redirect_to login_path
      return
    end
  end

  def admin_required
    if session[:punter_id] && Punter.find(session[:punter_id]) && Punter.find(session[:punter_id]).admin?
      return
    else
      flash[:error] = "Please login."
      return_here_after_login
      redirect_to login_path
      return
    end
  end

  def return_here_after_login
    session[:after_login] = request.request_uri
  end

end

