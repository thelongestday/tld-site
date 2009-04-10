require 'test_helper'

class ComatoseAdminControllerTest < ActionController::TestCase
  include PunterTestHelper
  fixtures :comatose_pages

  context "on GET to :comatose_admin calls :admin_required when not logged in" do
    setup do
      get :index
    end
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to :comatose_admin calls :admin_required when logged in as a user" do
    setup do
      login_as_user
      get :index
    end
    should_redirect_to("Login page") { login_path }
  end

  context "on GET to :comatose_admin calls :admin_required when logged in as an admin" do
    setup do
      login_as_admin
      get :index
    end
    should_respond_with :success
  end
end

