class Admin::PaypalLogController < Admin::AdminController
  active_scaffold :paypal_log do |config|
    config.columns = [ :item_number, :mc_gross, :payment_status, :updated_at ]
    config.actions = [ :list, :nested ]
    config.columns[:item_number].set_link('nested', :parameters => { :associations => :order })
    config.columns[:item_number].label = 'Order'
    config.columns[:mc_gross].label = 'Amount'
  end
end

