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

    context "looking at someone else's stuff if they're an admin" do
      setup do
        @p1 = Punter.generate! ; @p1.update_attribute(:admin, true)
        @p2 = Punter.generate!
        @o = Order.generate! { |o| o.owner = @p1 }
        @o2 = Order.generate! { |o| o.owner = @p2 }
        login_as(@p1)
        get :show, :id => @o2
      end

      should_respond_with :success
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

      context "where the number of children hasn't changed" do
        setup do
          @o = Order.generate!
          @o.confirm!
          login_as(@o.owner)
          put :update, :id => @o.to_param, :order_punter => { }, :order => { :children => '0' }
        end
        should_redirect_to("order show") { order_path(@o) }
        should_set_the_flash_to /locked/
      end

      context "where the number of children has changed" do
        setup do
          @o = Order.generate!
          @o.confirm!
          login_as(@o.owner)
          put :update, :id => @o.to_param, :order_punter => { }, :order => { :children => '3' }
        end
        should "update the number of children" do
          assert_equal 3, assigns(:order).children
        end

        should_redirect_to("order show") { order_path(@o) }
        should_set_the_flash_to /updated/
      end
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

    context "order collisions" do
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

        # one ticket also on another order
        @t1o2 = create_ticket(:punter => @p1, :order => @o2)

        # that are paid
        @o2.confirm!
        @o2.pay!
      end

      context "when an ticket has subsequently been bought by someone else" do
        setup do
          login_as(@o1.owner)
          get :show, :id => @o1
        end

        should "should zap the tickets on this order" do
          assert_does_not_contain @o1.tickets, @t1o1
        end

        should "leave the surviving tickets alone" do
          assert_contains @o1.tickets, @t2o1
          assert_contains @o1.tickets, @t3o1
        end

        should_assign_to :already
        should_render_template :collision
        
        should "leave the other order untouched" do
          assert_contains @o2.tickets, @t1o2
        end
      end

      context "when an ticket has been bought by this punter, but someone else has ordered it, via show" do
        setup do
          login_as(@o2.owner)
          get :show, :id => @o2
        end

        should "should not zap the tickets on this order" do
          assert_contains @o2.tickets, @t1o2
        end

        should_render_template :show
      end

      context "when multiple tickets have subsequently been bought by someone else, via confirm" do
        setup do
          @t2o2 = create_ticket(:punter => @p2, :order => @o2)
          login_as(@o1.owner)
          post :confirm, :id => @o1
        end

        should "should zap the tickets on this order" do
          assert_does_not_contain @o1.tickets, @t1o1
          assert_does_not_contain @o1.tickets, @t2o1
        end

        should "leave the surviving tickets alone" do
          assert_contains @o1.tickets, @t3o1
        end

        should_assign_to :already
        should_render_template :collision
        
        should "leave the other order untouched" do
          @o2.reload
          assert_contains @o2.tickets, @t1o2
          assert_contains @o2.tickets, @t2o2
          assert @o2.paid?
        end

        should "not confirm the order" do
          assert @o1.new?
        end
      end

      context "when tickets have subsequently been bought by someone else and this order is confirmed" do
        setup do
          login_as(@o1.owner)
          @o1.confirm!
          post :confirm, :id => @o1
        end

        should "unconfirm the order" do
          @o1.reload
          assert @o1.new?
        end
      end
    end

    context "with a confirmed order" do
      def setup
        @o = Order.generate!
        @o.confirm!
        login_as(@o.owner)
        get :show, :id => @o.to_param
      end
      # XXX TypeError: can't convert Array into String
      # should_render_a_form
    end

    context "adding tickets to an order " do
      setup do
        @p1 = Punter.generate! ; @p1.confirm!
        @p2 = Punter.generate! ; @p2.confirm!
        @p3 = Punter.generate! ; @p3.confirm!
        @i1 = Invitation.create!(:inviter => @p1, :invitee => @p2)
        login_as(@p1)
      end

      context "via :create" do
        should "not add punters who aren't candidates" do
          assert_contains @p1.unpaid_ticket_candidates, @p1
          assert_contains @p1.unpaid_ticket_candidates, @p2

          post :create, :order_punter => { @p1.id.to_s => "1", @p2.id.to_s => "1", @p3.id.to_s => "1" }, :order => { :children => 0 }
          @o = assigns(:order)
          punters = @o.tickets.map { |t| t.punter }

          assert_contains punters, @p1
          assert_contains punters, @p2
          assert_does_not_contain @o.tickets.map { |t| t.punter }, @p3
        end

        should "update children" do
          post :create, :order_punter => { @p1.id.to_s => "1", @p2.id.to_s => "1", @p3.id.to_s => "1" }, :order => { :children => 3 }
          @o = assigns(:order)
          assert_equal 3, @o.children
        end

      end

      context "via :update" do
        setup do
          @o = Order.create
          @o.update_attribute(:owner, @p1)
        end

        should "not add punters who aren't candidates" do
          assert_contains @p1.unpaid_ticket_candidates, @p1
          assert_contains @p1.unpaid_ticket_candidates, @p2

          put :update, :id => @o.to_param, :order_punter => { @p1.id.to_s => "1", @p2.id.to_s => "1", @p3.id.to_s => "1" }, :order => { :children => 0 } 
          punters = @o.tickets.map { |t| t.punter }

          assert_contains punters, @p1
          assert_contains punters, @p2
          assert_does_not_contain @o.tickets.map { |t| t.punter }, @p3
        end

        should "update children" do
          put :update, :id => @o.to_param, :order_punter => { @p1.id.to_s => "1", @p2.id.to_s => "1", @p3.id.to_s => "1" }, :order => { :children => 2 } 
          @o = assigns(:order)
          assert_equal 2, @o.children
        end
      end
    end
  end

  def setup
    @o = Order.generate!
    @o.owner.confirm!
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
      post :create, :order_punter => { }, :order => { :children => 0 }
    end

    assert_difference('Ticket.count') do
      post :create, :order_punter => { @o.owner.id => "1" }, :order => { :children => 0 }
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
    p = Punter.generate! ; p.confirm!
    t = create_ticket(:order => @o, :punter => p)
    @o.update_attribute(:owner, p)
    login_as(p)

    put :update, :id => @o.to_param, :order_punter => { p.id => "1" }, :order => { :children => 0 }

    assert_does_not_contain @o.tickets.map { |t| t.id} , t
    assert_equal @o.tickets.first.punter, p
    assert_redirected_to order_path(assigns(:order))
  end

  test "should delete order if submitted with no order_punters" do
    put :update, :id => @o.to_param
    assert_redirected_to orders_path
    assert_raise(ActiveRecord::RecordNotFound) { Order.find(@o.id) }
  end

end
