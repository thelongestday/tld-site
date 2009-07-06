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
        Punter.expects(:authenticate_by_password).with('foo@example.com', 'foobar').raises(PunterException)
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
    should_set_the_flash_to /You have logged out/
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to :confirm" do
    context "with incorrect parameters" do
      setup do
        Punter.expects(:authenticate_by_token).with('abc').raises(PunterException)
        get :confirm, { :email => 'foo@example.com', :token => 'abc' } 
      end
      # should_set_the_flash_to /Incorrect/
      should_redirect_to("Home page") { '/' }
    end

    context "with correct parameters" do
      setup do
        @punter = Punter.generate!
        @punter.inviters << Punter.generate!
        @punter.invite!
        Punter.expects(:authenticate_by_token).with('abc').returns(@punter)
        @punter.expects(:confirm!)
        get :confirm, { :token => 'abc' } 
      end

      should_set_session(:punter_id) { @punter.id }
      should_set_the_flash_to /Thanks for signing/
      should_respond_with :success
      should_render_template 'edit'
      should "set the punter to confirmed" do
        assert @punter.confirmed?
      end
    end
  end

  context "on GET to :reset" do
    setup { get :reset }
    should_render_a_form
  end

  context "on POST to :reset" do
    context "with absent parameters" do
      setup { post :reset }
      should_set_the_flash_to /Incorrect/
      should_render_a_form
    end

    context "with incorrect parameters" do
      setup { post :reset, :punter => { :email => '' } }
      should_set_the_flash_to /Incorrect/
      should_render_a_form
    end

    context "with a Punter that doesn't exist" do
      setup do
        Punter.expects(:find_by_email).with('foo@example.com').returns(nil)
        post :reset, :punter => { :email  => 'foo@example.com' }
      end
      should_render_a_form
      should_set_the_flash_to /don't have anyone/
    end

    context "with a Punter that does exist" do
      setup do
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
        Punter.expects(:find_by_email).with('foo@example.com').returns(@punter)
        @punter.expects(:reset!)
        post :reset, :punter => { :email  => 'foo@example.com' }
      end
      should_redirect_to("Login page") { login_path }
      should_set_the_flash_to /check your mail/
    end

  end

  context "on GET to :show as logged in user" do

    context "with no invitees" do
    setup do
      login_as_user
      get :show
    end
      should_respond_with :success
      # FIXME - eh? why is @r nil?
      # assert_contains @response.body, /You haven't invited anyone/
    end
  end

  context "on GET to :invite" do
    setup do
      login_as_user
      get :invite
    end

    should_redirect_to("user show path") { user_show_path }
  end

  context "on POST to :invite" do
    context "with invalid params" do
      setup do
        login_as_user
        post :invite, { :invitee => { :name => 'a', :email => 'b' } }
      end

      should_render_template :show
      should_render_a_form
    end

    context "with valid params" do
      setup do
        login_as_user
        post :invite, { :invitee => { :name => 'foo', :email => 'new@example.com' } }
      end

      should_redirect_to("user_show_path") { user_show_path }
    end

    context "inviting self" do
      setup do
        login_as_user
        post :invite, { :invitee => { :name => 'foo', :email => 'foo@example.com' } }
      end

      should_redirect_to("user_show_path") { user_show_path }
      should_set_the_flash_to /kinky/
    end
  end

  context "on GET to :update" do
    setup do
      login_as_user
      get :update
    end
    should_redirect_to("user page") { user_show_path }
  end

  context "on POST to udpate" do
    setup do
      login_as_user
    end

    context "with absent params" do
      context "redirect to user page" do
        setup do 
          put :update
        end
        should_redirect_to("user page") { user_show_path }
      end
    end

    context "with wrong params" do
      context "redirect to user page" do
        setup do
          put :update, { :foo => 'bar' }
        end
        should_redirect_to("user page") { user_show_path }
      end
    end

    # these aren't actually testing the expectations :/
    context "when no password is needed" do
      context "and none is supplied" do
        context "set the remaining attributes" do
          setup do
            @punter.expects(:update_attributes).with({:name =>'bar'}).returns(true)
            put :update, { :punter => { :name => 'bar' } }
          end
#          should_set_the_flash_to /updated/
#          should_redirect_to("user page") { user_show_path }
        end
      end
      context "and one is supplied" do
        context "set the password" do
          setup do
            @punter.expects(:set_new_password).with(true)
            @punter.expects(:update_attributes).with({ :password => 'foofoo', :password_confirmation => 'foofoo' }).returns(true) 
            put :update, { :punter => { :password => 'foofoo', :password_confirmation => 'foofoo' } }
          end
#        should_set_the_flash_to /updated/
#        should_redirect_to("user page") { user_show_path }
        end
      end
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
        @controller.expects(:render)
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
        @controller.expects(:render).at_least_once
        get :reject
      end
      should_assign_to :punter, :equals => @punter
      # should_render_template :show # :reject renders :show
    end

    context "when in a state of signup flail" do
      context "calling login_required" do
        setup do
          @punter = Punter.generate!
          @punter.confirm!
          @punter.update_attribute(:name, nil)
          session[:punter_id] = @punter.id
        end
        context ":show" do
          setup do
            get :show
          end
          should_set_the_flash_to /Please update/
          should_redirect_to('edit page') { user_edit_path }
        end
        context ":edit" do
          setup do
            get :edit
          end
          should_respond_with :success
        end
        context ":update" do
          setup do
            put :update, { :punter => { :name => 'bar' } }
          end
          should_respond_with :success
        end
      end
    end
  end

end

