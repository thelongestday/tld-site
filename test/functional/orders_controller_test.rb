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
        @o.confirm!
        login_as(@o.owner)
        put :update, :id => @o.to_param, :order_punter => { }
      end

      should_redirect_to("order show") { order_path(@o) }
      should_set_the_flash_to /locked/
    end

    context "cancelling an order" do
      context "that's new" do
        setup do
          @o = Order.generate!
          @t = create_ticket(:punter => @o.owner, :order => @o)
          login_as(@o.owner)
          delete :destroy, :id => @o.to_param
        end

        should "cancel the order" do
          @o.reload
          assert @o.cancelled?
        end

        should "delete the tickets" do
          assert @o.tickets.empty?
        end

        should_redirect_to("orders path") { orders_path }
        should_set_the_flash_to /Order cancelled/
      end

      context "that's confirmed" do
        setup do
          @o = Order.generate!
          @o.confirm!
          login_as(@o.owner)
          delete :destroy, :id => @o.to_param
        end

        should "cancel the order" do
          @o.reload
          assert @o.cancelled?
        end

        should_redirect_to("orders path") { orders_path }
        should_set_the_flash_to /Order cancelled/
      end

      context "that's paid" do
        setup do
          @o = Order.generate!
          @o.confirm!
          @o.pay!
          login_as(@o.owner)
          delete :destroy, :id => @o.to_param
        end

        should "not cancel the order" do
          @o.reload
          assert @o.paid?
        end

        should_redirect_to("orders path") { orders_path }
        should_set_the_flash_to /You can't/
      end
    end

    context "confirming an order" do
      context "that's new" do
        setup do
          @o = Order.generate!
          login_as(@o.owner)
          post :confirm, :id => @o.to_param
        end

        should "confirm the order" do
          @o.reload
          assert @o.confirmed?
        end

        should_redirect_to("order path") { order_path(@o) }
        should_set_the_flash_to /Order confirmed/
      end

      context "that's confirmed" do
        setup do
          @o = Order.generate!
          @o.confirm!
          login_as(@o.owner)
          post :confirm, :id => @o.to_param
        end

        should "do nothing" do
          @o.reload
          assert @o.confirmed?
        end

        should_redirect_to("order path") { order_path(@o) }
        should_set_the_flash_to /You can't/
      end

      context "that's paid" do
        setup do
          @o = Order.generate!
          @o.confirm!
          @o.pay!
          login_as(@o.owner)
          post :confirm, :id => @o.to_param
        end

        should "not confirm the order" do
          @o.reload
          assert @o.paid?
        end

        should_redirect_to("order path") { order_path(@o) }
        should_set_the_flash_to /You can't/
      end
    end

    context "when an ticket has subsequently been bought by someone else" do
      setup do
        @p1 = Punter.generate!
        @p2 = Punter.generate!
        @p3 = Punter.generate!
        @o1 = Order.generate!
        @o2 = Order.generate!

        # three tickets on this order
        @t1o1 = create_ticket(:punter => @p1, :order => @o1)
        @t2o1 = create_ticket(:punter => @p2, :order => @o1)
        @t3o1 = create_ticket(:punter => @p3, :order => @o1)

        # two tickets also on another order
        @t1o2 = create_ticket(:punter => @p1, :order => @o2)
        @t2o2 = create_ticket(:punter => @p2, :order => @o2)

        # that are paid
        @o2.confirm!
        @o2.pay!

        login_as(@o1.owner)
        get :show, :id => @o1

      end

      should "should zap the tickets on this order" do
        assert_does_not_contain @o1.tickets, @t1o1
        assert_does_not_contain @o1.tickets, @t2o1
      end

      should "leave the surviving tickets alone" do
        assert_contains @o1.tickets, @t3o1
      end

      should_set_the_flash_to /dithering/
      
      should "leave the other order untouched" do
        assert_contains @o2.tickets, @t1o2
        assert_contains @o2.tickets, @t2o2
      end
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
