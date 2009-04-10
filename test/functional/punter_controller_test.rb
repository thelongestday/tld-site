require 'test_helper'

class PunterControllerTest < ActionController::TestCase

  include PunterTestHelper

  context "on GET to :login" do
    setup  { get :login }
    should_set_session(:punter_id) { nil }
    should_render_a_form
  end

  context "on POST to :login with bad parameters" do
    setup { post :login, :foo => { } }
    should_set_the_flash_to :notice => 'Incorrect details entered. Please try again.'
    should_render_a_form
  end

  context "on POST to :login with missing password" do
    setup { post :login, :punter => { :email => 'foo@example.com' } }
    should_set_the_flash_to :notice => 'Incorrect details entered. Please try again.'
    should_render_a_form
  end

  context "on POST to :login with missing email" do
    setup { post :login, :punter => { :password => 'woofoo' } }
    should_set_the_flash_to :notice => 'Incorrect details entered. Please try again.'
    should_render_a_form
  end

  context "on POST to :login" do
    context "with incorrect user details" do
      setup do
        Punter.expects(:authenticate_by_password).with('foo@example.com', 'foobar').raises(RuntimeError)
        post :login, :punter => { :email => 'foo@example.com', :password => 'foobar' }
      end
    should_set_the_flash_to :notice => 'Incorrect details entered. Please try again.'
    should_render_a_form
    end

    context "with correct user details and no :after_login key in session" do
      setup do
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        Punter.expects(:authenticate_by_password).with('foo@example.com', 'foobar').returns(@punter)
        post :login, :punter => { :email => 'foo@example.com', :password => 'foobar' }
      end
      should_set_session(:punter_id) { @punter.id }
      should_redirect_to("User info page") { user_show_path }
    end

    context "with correct user details and :after_login key in session" do
      setup do
        session[:after_login] = '/over/here'
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        Punter.expects(:authenticate_by_password).with('foo@example.com', 'foobar').returns(@punter)
        post :login, :punter => { :email => 'foo@example.com', :password => 'foobar' }
      end
      should_set_session(:punter_id) { @punter.id }
      should_redirect_to("stored URI") { '/over/here' }
    end
  end

  context "on GET to :logout" do
    setup { get :logout }
    should_set_session(:punter_id) { nil }
    should_set_the_flash_to :notice => 'You have logged out.'
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to :confirm" do
    context "with incorrect parameters" do
      setup do
        Punter.expects(:authenticate_by_token).with('abc').raises(RuntimeError)
        get :confirm, { :email => 'foo@example.com', :token => 'abc' } 
      end
      should_set_the_flash_to :notice => 'Que?'
      should_redirect_to("Login page") { login_path }
    end

    context "with correct parameters" do
      setup do
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        @punter.invite!
        Punter.expects(:authenticate_by_token).with('abc').returns(@punter)
        @punter.expects(:confirm!)
        get :confirm, { :token => 'abc' } 
      end

      should_set_session(:punter_id) { @punter.id }
      should_redirect_to("User edit page") { user_edit_path }
      
    end

  end

  context "as a consumer of PunterSystem" do
    context "calling login_required without a punter_id in session" do
      setup { get :show }
      should_not_assign_to :punter
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /Please login/
    end

    context "calling login_required with a bogus punter_id in session" do
      setup do
        session[:punter_id] = 732
        Punter.expects(:find).with(732).returns(nil)
        get :show
      end
      should_not_assign_to :punter
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /Please login/
    end

    context "calling login_required with a legitmate punter_id in session" do
      setup do
        session[:punter_id] = 732
        Punter.expects(:find).with(732).returns(Punter.create!(:name => 'foo bar', :email => 'foo@example.com'))
        get :show
      end
      should_assign_to :punter, :equals => @punter
      should_respond_with :success
    end

    context "calling admin_required without a punter_id in session" do
      setup { get :reject }
      should_not_assign_to :punter
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /Please login/
    end

    context "calling admin_required with a bogus punter_id in session" do
      setup do
        session[:punter_id] = 732
        Punter.expects(:find).with(732).returns(nil)
        get :reject
      end
      should_not_assign_to :punter
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /Please login/
    end

    context "calling admin_required with a legitimate punter_id in session that isn't an admin" do
      setup do
        session[:punter_id] = 732
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        @punter.expects(:admin?).returns(false)
        Punter.expects(:find).with(732).returns(@punter)
        get :reject
      end
      should_not_assign_to :punter
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /Please login/
    end

    context "calling admin_required with a legitimate punter_id in session that is an admin" do
      setup do
        session[:punter_id] = 732
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        Punter.expects(:find).with(732).returns(@punter)
        @punter.expects(:admin?).returns(true)
        get :reject
      end
      should_assign_to :punter, :equals => @punter
      should_render_template :show # :reject renders :show
    end
  end

end

