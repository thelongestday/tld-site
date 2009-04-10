module PunterTestHelper
  def login_as_user
    @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    session[:punter_id] = @punter.id
  end

  def login_as_admin
    @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com', :admin => true)
    session[:punter_id] = @punter.id
  end
end


