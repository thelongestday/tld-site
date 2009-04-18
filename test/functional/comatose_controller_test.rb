require 'test_helper'

class ComatoseControllerTest < ActionController::TestCase
  include PunterTestHelper

  context "on GET to a page on the :the-longest-day-2009 mountpoint" do
    setup do
      @controller.expects(:render).twice
      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>[], "root"=>"/", "index"=>"the-longest-day-2009" 
    end
    should_respond_with :success
  end

  context "on GET to a page on the :invitees mountpoint when not logged in" do
    setup do
      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>["sekrit-page"], "root"=>"/invitees", "index"=>"invitees"
    end
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to a page on the :invitees mountpoint when logged in" do
    setup do
      login_as_user
      @controller.expects(:render).twice
      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>["sekrit-page"], "root"=>"/invitees", "index"=>"invitees"
    end
    should_respond_with :success
  end

  context "on GET to a page on the :attendees mountpoint when not logged in" do
    setup do
      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>["sekrit-page"], "root"=>"/attendees", "index"=>"attendees"
    end
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to a page on the :attendees mountpoint when logged in but no ticket bought" do
    setup do
      login_as_user
      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>["sekrit-page"], "root"=>"/attendees", "index"=>"attendees"
    end
    should_redirect_to("User page") { user_show_path }
  end

#  context "on GET to a page on the :attendees mountpoint when logged in with ticket bought" do
#    setup do
#      login_as_user
#      @punter.expects(:has_paid_ticket?).returns(true)
#      get :show, "use_cache"=>"true", "layout"=>"tld", "cache_path"=>nil, "page"=>["sekrit-page"], "root"=>"/attendees", "index"=>"attendees"
#    end
#    should_respond_with :success
#  end
end

