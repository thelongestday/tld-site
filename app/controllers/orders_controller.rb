class OrdersController < ApplicationController
  include PunterSystem
  layout 'tld'

  before_filter :login_required
  before_filter :retrieve_order,    :only => [ :edit , :show, :update ]
  before_filter :check_order_owner, :only => [ :edit , :show, :update ]
  verify :params => :order_punter, :only => [ :create ], :redirect_to => :user_show_path

  # GET /orders
  def index
    @orders = Order.find_all_by_owner_id(@punter)
    @paid_punters = @punter.paid_ticket_candidates
    @unpaid_punters = @punter.unpaid_ticket_candidates
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = {}
  end

  # GET /orders/1/edit
  def edit
    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = Hash.new { |h,k| h[k] = "0" }
    @order.tickets.each { |t| @order_punters[t.punter.id] = "1" }
  end

  # POST /orders
  def create
    @order = Order.create
    @order.update_attribute(:owner, @punter) # protected
    params[:order_punter].keys.each { |p| @order.add_ticket_by_punter_id(p) }
    if @order.save
      flash[:notice] = 'Order was successfully created.'
      redirect_to order_path(@order)
    else
      render :action => "new" 
    end
  end

  # PUT /orders/1
  def update
    # first remove all the previous tickets
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
