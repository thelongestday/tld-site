class OrdersController < ApplicationController
  protect_from_forgery :except => :ack

  include PunterSystem
  layout 'tld_app'

  before_filter :login_required
  before_filter :retrieve_order,        :only => [ :ack, :confirm, :destroy, :edit, :show, :update, :children, :pdf ]
  before_filter :check_order_owner,     :only => [ :ack, :confirm, :destroy, :edit, :show, :update, :children, :pdf ]
  before_filter :check_order_collision, :only => [ :confirm, :show ]
  verify :params => :order_punter,      :only => [ :create ], :redirect_to => :orders_path

  def order_frame
    render :layout => 'tld_frame'
  end

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
  end

  def pdf
    if @order.paid?
      filename = TicketPdf::pdf_for_order(@order)
      send_file(filename, :type => 'appplication/pdf')
    else
      redirect_to :show
    end
  end

  # GET /orders/new
  def new
    redirect_to orders_path
    return

    @order = Order.new
    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = {}
    @event = Site::Config.event
    @children_select = (0..5).map { |c| [ c.to_s, c ] }
  end

  # GET /orders/1/edit
  def edit
    redirect_to orders_path
    return

    @unpaid_punters = @punter.unpaid_ticket_candidates
    @order_punters = Hash.new { |h,k| h[k] = "0" }
    @order.tickets.each { |t| @order_punters[t.punter.id] = "1" }
    @event = Site::Config.event
    @children_select = (0..5).map { |c| [ c.to_s, c ] }
  end

  def children
    @children_select = (0..5).map { |c| [ c.to_s, c ] }
  end

  def confirm
    redirect_to orders_path
    return

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
    redirect_to orders_path
    return

    @order = Order.create
    @order.update_attribute(:owner, @punter) # protected

    candidates = @punter.unpaid_ticket_candidates.map { |p| p.id }
    punters = params[:order_punter].keys.find_all { |p| candidates.include?(p.to_i) }
    logger.debug("#{params[:order_punter].keys.join(',')} vs #{punters.join(',')} via #{candidates.join(',')}")
    punters.each { |p| @order.add_ticket_by_punter_id(p) }

    @order.update_attribute(:children, params[:order][:children].to_i)

    if @order.save
      flash[:notice] = 'Order created.'
      redirect_to order_path(@order)
    else
      render :action => "new" 
    end
  end

  # PUT /orders/1
  def update
    redirect_to user_show_path
    return

    # check order can be updated
    unless @order.new?
      # allow # of children to be updated
      if params[:order][:children].to_i != @order.children
        @order.update_attribute(:children, params[:order][:children].to_i)
        @order.reload
        flash[:notice] = 'Order updated.'
        redirect_to order_path(@order)
        return
      else
        flash[:error] = 'Order is locked.'
        redirect_to order_path(@order)
        return
      end
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
    candidates = @punter.unpaid_ticket_candidates.map { |p| p.id }
    punters = params[:order_punter].keys.find_all { |p| candidates.include?(p.to_i) }
    punters.each { |p| @order.add_ticket_by_punter_id(p) }

    @order.update_attribute(:children, params[:order][:children].to_i)

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

  def check_order_collision
    # check no-one on the order has since had a ticket bought for them
    unless @order.paid? || @order.cancelled?
      @already = @order.tickets.find_all { |t| t.punter.has_paid_ticket? }
      unless @already.empty?
        @already.each { |t| t.delete }
        if @order.confirmed?
          @order.unconfirm!
        end
        @order.reload
        render :collision
        return
      end
    end
  end

  def check_order_owner
    unless @order.owner == @punter || @punter.admin?
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
