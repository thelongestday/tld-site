class PaypalLog < ActiveRecord::Base
  belongs_to :order, :foreign_key => 'item_number'

  def log(notify)
    log_keys = %w{ item_number txn_id receiver_id payer_id payment_status mc_gross mc_fee mc_currency invoice quantity }
    params = {}
    log_keys.each { |k| params[k] = notify.params[k] }
    self.update_attributes(params)
  end
    
end
