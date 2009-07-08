class Admin::AdminController < ApplicationController
  include PunterSystem
  before_filter :admin_required
  layout 'admin'

  def index
    @punter_stats = {}
    @order_stats  = {}
    @ticket_stats = {}
    @paypal_stats = {}
    @signup_stats = {}

    @punter_stats[:total]      = Punter.count
    @punter_stats[:new ]       = Punter.count(:conditions => [ "state = 'new'" ] )
    @punter_stats[:invited ]   = Punter.count(:conditions => [ "state = 'invited'" ] )
    @punter_stats[:confirmed ] = Punter.count(:conditions => [ "state = 'confirmed'" ] )
    @punter_stats[:flailed ]   = Punter.count(:conditions => [ "state = 'confirmed' AND name IS NULL" ] )

    @signup_stats[:total]      = Site::Config.signup_user.invitees.length
    @signup_stats[:tickets]    = Site::Config.signup_user.invitees.inject(0) { |t,p| t+= p.orders.inject(0) { |n,o| n += o.tickets.length } }

    @order_stats[:total]      = Order.count
    @order_stats[:new ]       = Order.count(:conditions => [ "state = 'new'" ] )
    @order_stats[:confirmed ] = Order.count(:conditions => [ "state = 'confirmed'" ] )
    @order_stats[:paid ]      = Order.count(:conditions => [ "state = 'paid'" ] )

    tickets = []
    paid_orders = Order.find_all_by_state('paid', :include => :tickets)
    paid_orders.each { |o| o.tickets.each { |t| tickets << t } }

    @ticket_stats[:total] = tickets.length
    @ticket_stats[:test]  = tickets.find_all { |t| t.cost == 100 }.length
    @ticket_stats[:real]  = @ticket_stats[:total] - @ticket_stats[:test]

    @children = paid_orders.inject(0) { |t,o| t += o.children }

    gross = 0
    commission = 0
    PaypalLog.find_all_by_payment_status('Completed').each do |pp|
      gross      += (pp.mc_gross * 100)
      commission += (pp.mc_fee   * 100)
    end
    @paypal_stats[:gross] = gross
    @paypal_stats[:commission] = commission
    @paypal_stats[:expected] = gross - commission
    @paypal_stats[:face] = Site::Config.event.cost * @ticket_stats[:real] 

  end

  def tickets
    paid_orders = Order.find_all_by_state('paid')
    @tickets = []
    paid_orders.each { |o| @tickets << o.tickets }
    @tickets.flatten!

    response.headers['Content-Type'] = 'text/csv; charset=iso-8859-1; header=present'
    response.headers['Content-Disposition'] = 'attachment; filename=tickets.csv'
    
    render :layout => false
  end

  def shame
    cabal = Punter.find_all_by_admin(true, :include => :invitees)

    @shame = []

    cabal.each do |p|
      i = p.invitees.length
      a = p.invitees.find_all { |x| x.confirmed? }.length
      logger.info("#{p} - #{i} - #{a}")
      @shame.push({ :punter => p,
                    :invited => i,
                    :accepted => a })
    end
  end

end
