class OrdersController < ApplicationController
  protect_from_forgery :except => :ack

  include PunterSystem
  layout 'tld'

  before_filter :login_required
  before_filter :retrieve_order,    :only => [ :ack, :confirm, :destroy, :edit, :show, :update ]
  before_filter :check_order_owner, :only => [ :ack, :confirm, :destroy, :edit, :show, :update ]
  verify :params => :order_punter, :only => [ :create ], :redirect_to => :orders_path

  # GET /orders
  def index
    @orders = Order.find_all_by_owner_id(@punter)
    @paid_punters = @punter.paid_ticket_candidates
    @unpaid_punters = @punter.unpaid_ticket_candidates
  end

  def ack
  end

  # GET /orders/1
  def show
    # check no-one on the order has since had a ticket bought for them
    already = @order.tickets.find_all { |t| t.punter.has_paid_ticket? }
    unless already.empty?
      already.each { |t| t.delete }
      flash[:notice] = "Whilst you were dithering with this order, #{already.map { |t| t.punter.name }.join(', ')} got their tickets elsewhere! They have been removed from your order."
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = {}
    @event = Site::Config.event
  end

  # GET /orders/1/edit
  def edit
    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = Hash.new { |h,k| h[k] = "0" }
    @order.tickets.each { |t| @order_punters[t.punter.id] = "1" }
    @event = Site::Config.event
  end

  def confirm
    begin
      @order.confirm!
    rescue AASM::InvalidTransition
      flash[:error] = "You can't confirm this order."
      redirect_to(order_path(@order))
      return
    end

    flash[:notice] = 'Order confirmed.'
    redirect_to(order_path(@order))
  end

  # POST /orders
  def create
    @order = Order.create
    @order.update_attribute(:owner, @punter) # protected
    params[:order_punter].keys.each { |p| @order.add_ticket_by_punter_id(p) }
    if @order.save
      flash[:notice] = 'Order created.'
      redirect_to order_path(@order)
    else
      render :action => "new" 
    end
  end

  # PUT /orders/1
  def update
    # check order can be updated
    unless @order.new?
      flash[:error] = 'Order is locked.'
      redirect_to order_path(@order)
      return
    end

    # remove all the previous tickets
    @order.tickets.each { |t| t.delete }

    # if we've not order_punters, we've had all tickets removed - kill the order
    unless params.has_key?(:order_punter)
      @order.delete
      flash[:notice] = 'Order cancelled - no tickets!'
      redirect_to orders_path
      return
    end

    # add new tickets
    params[:order_punter].keys.each { |p| @order.add_ticket_by_punter_id(p) }
    flash[:notice] = 'Order was successfully updated.'
    redirect_to order_path(@order)
  end
  
  # DELETE /posts/1
  def destroy
    begin
      @order.cancel!
    rescue AASM::InvalidTransition
      flash[:error] = "You can't cancel this order."
      redirect_to(orders_path)
      return
    end

    @order.tickets.each { |t| t.delete }

    flash[:notice] = 'Order cancelled.'
    redirect_to(orders_path)
  end
  

  protected

  def check_order_owner
    unless @order.owner == @punter
      flash[:error] = 'Order not found.'
      redirect_to orders_path
      return
    end
  end

  def retrieve_order
    begin
      @order = Order.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Order not found.'
      redirect_to orders_path
      return
    end
  end

end
