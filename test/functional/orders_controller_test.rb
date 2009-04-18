require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include PunterTestHelper
  fixtures :orders

  context "As a logged out punter" do
    setup do
      session.delete(:punter_id)
      get :index
    end
    should_redirect_to("login page") { login_path }
  end

  context "As a logged in punter" do
    context "looking at someone else's stuff" do
      setup do
        @p1 = Punter.generate!
        @p2 = Punter.generate!
        @o1 = Order.generate! { |o| o.owner = @p1 }
        @o2 = Order.generate! { |o| o.owner = @p2 }
        login_as(@p1)
        get :show, :id => @o2
      end

      should_redirect_to("orders index") { orders_path }
      should_set_the_flash_to /Order not found/
    end

    context "looking at a non-existent order" do
      setup do
        @p1 = Punter.generate!
        @o1 = Order.generate! { |o| o.owner = @p1 }
        login_as(@p1)
        get :show, :id => 732
      end

      should_redirect_to("orders index") { orders_path }
      should_set_the_flash_to /Order not found/
    end
  end

  def setup
    @o1 = Order.generate!
    login_as(@o1.owner)
  end

  test "should get index with that punter's orders" do
    Order.expects(:find_all_by_owner_id).with(@o1.owner).returns([ @o1 ] )
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, :order => { }
    end

    assert_redirected_to order_path(assigns(:order))
  end

  test "should show order" do
    get :show, :id => @o1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @o1.to_param
    assert_response :success
  end

  test "should update order" do
    put :update, :id => @o1.to_param, :order => { }
    assert_redirected_to order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, :id => @o1.to_param
    end

    assert_redirected_to orders_path
  end
end
