module PunterTestHelper
  def login_as_user
    @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    session[:punter_id] = @punter.id
  end

  def login_as_admin
    @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    @punter.update_attribute(:admin, true)
    session[:punter_id] = @punter.id
  end

  def login_as(punter)
    session[:punter_id] = punter
  end

end


