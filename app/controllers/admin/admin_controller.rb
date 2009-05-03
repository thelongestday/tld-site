class Admin::AdminController < ApplicationController
  include PunterSystem
  before_filter :admin_required
  layout 'admin'

  def index
    @punter_stats = {}
    @order_stats  = {}
    @ticket_stats = {}
    @paypal_stats = {}

    @punter_stats[:total]      = Punter.count
    @punter_stats[:new ]       = Punter.count(:conditions => [ "state = 'new'" ] )
    @punter_stats[:invited ]   = Punter.count(:conditions => [ "state = 'invited'" ] )
    @punter_stats[:confirmed ] = Punter.count(:conditions => [ "state = 'confirmed'" ] )
    @punter_stats[:flailed ]   = Punter.count(:conditions => [ "state = 'confirmed' AND name IS NULL" ] )

    @order_stats[:total]      = Order.count
    @order_stats[:new ]       = Order.count(:conditions => [ "state = 'new'" ] )
    @order_stats[:confirmed ] = Order.count(:conditions => [ "state = 'confirmed'" ] )
    @order_stats[:paid ]      = Order.count(:conditions => [ "state = 'paid'" ] )

    tickets = []
    Order.find_all_by_state('paid').each { |o| o.tickets.each { |t| tickets << t } }

    @ticket_stats[:total] = tickets.length
    @ticket_stats[:test]  = tickets.find_all { |t| t.cost == 100 }.length
    @ticket_stats[:real]  = @ticket_stats[:total] - @ticket_stats[:test]


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

end
