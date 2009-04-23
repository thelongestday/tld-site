class Admin::AdminController < ApplicationController
  include PunterSystem
  before_filter :admin_required
  layout 'admin'

  def index
    @punter_stats = {}
    @order_stats  = {}
    @ticket_stats = {}

    @punter_stats[:total]      = Punter.count
    @punter_stats[:new ]       = Punter.count(:conditions => [ "state = 'new'" ] )
    @punter_stats[:invited ]   = Punter.count(:conditions => [ "state = 'invited'" ] )
    @punter_stats[:confirmed ] = Punter.count(:conditions => [ "state = 'confirmed'" ] )

    @order_stats[:total]      = Order.count
    @order_stats[:new ]       = Order.count(:conditions => [ "state = 'new'" ] )
    @order_stats[:confirmed ] = Order.count(:conditions => [ "state = 'confirmed'" ] )
    @order_stats[:paid ]      = Order.count(:conditions => [ "state = 'paid'" ] )

    t = 0
    Order.find_all_by_state('paid').each { |o| t += o.tickets.length }
    @ticket_stats[:paid] = t
  end

end