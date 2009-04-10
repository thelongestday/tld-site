require 'test_helper'

class ComatoseAdminControllerTest < ActionController::TestCase
  context "on GET to :comatose_admin calls :admin_required" do
    setup do
      get :comatose_admin 
    end
    ComatoseAdminController.expects(:admin_required)
  end
end

