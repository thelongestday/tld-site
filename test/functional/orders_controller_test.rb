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
        @o = Order.generate! { |o| o.owner = @p1 }
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
        @o = Order.generate! { |o| o.owner = @p1 }
        login_as(@p1)
        get :show, :id => 732
      end

      should_redirect_to("orders index") { orders_path }
      should_set_the_flash_to /Order not found/
    end

    context "trying to update a non-new order" do
      setup do
        @o = Order.generate!
        @o.mark_ordered!
        login_as(@o.owner)
        put :update, :id => @o.to_param, :order_punter => { }
      end

      should_redirect_to("order show") { order_path(@o) }
      should_set_the_flash_to /locked/
    end
  end

  def setup
    @o = Order.generate!
    login_as(@o.owner)
  end

  test "should get index with that punter's orders" do
    Order.expects(:find_all_by_owner_id).with(@o.owner).returns([ @o ] )
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:unpaid_punters)
    assert_not_nil assigns(:paid_punters)
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:unpaid_punters)
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, :order_punter => { }
    end

    assert_difference('Ticket.count') do
      post :create, :order_punter => { @o.owner.id => "1" }
    end

    assert_redirected_to order_path(assigns(:order))
  end

  test "should show order" do
    get :show, :id => @o.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @o.to_param
    assert_response :success
  end

  test "should update order, deleting and replacing tickets" do
    p = Punter.generate!
    t = Ticket.create
    t.update_attribute(:cost,   Site::Config.event.cost)
    t.update_attribute(:event,  Site::Config.event)
    t.update_attribute(:order,  @o)
    t.update_attribute(:punter, p)
    @o.tickets << t
    put :update, :id => @o.to_param, :order_punter => { p.id => "1" }
    assert_does_not_contain @o.tickets, t
    assert_equal @o.tickets.first.punter, p
    assert_redirected_to order_path(assigns(:order))
  end

  test "should delete order if submitted with no order_punters" do
    put :update, :id => @o.to_param
    assert_redirected_to orders_path
    assert_raise(ActiveRecord::RecordNotFound) { Order.find(@o.id) }
  end

end
