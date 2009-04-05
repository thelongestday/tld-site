require 'test_helper'

class PunterControllerTest < ActionController::TestCase
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
        Punter.expects(:authenticate_by_email).with('foo@example.com', 'foobar').raises(RuntimeError)
        post :login, :punter => { :email => 'foo@example.com', :password => 'foobar' }
      end
    should_set_the_flash_to :notice => 'Incorrect details entered. Please try again.'
    should_render_a_form
    end

    context "with correct user details" do
      setup do
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        Punter.expects(:authenticate_by_email).with('foo@example.com', 'foobar').returns(@punter)
        post :login, :punter => { :email => 'foo@example.com', :password => 'foobar' }
      end
      should_set_session(:punter_id) { @punter.id }
      should_redirect_to("User info page") { user_show_path }
    end
  end

  context "on GET to :logout" do
    setup { get :logout }
    should_set_session(:punter_id) { nil }
    should_set_the_flash_to :notice => 'You have logged out.'
    should_redirect_to("Login page") { login_path }
  end

end
