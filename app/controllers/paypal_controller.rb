class PaypalController < ApplicationController
  protect_from_forgery :except => :ipn

  def ipn
    return if request.get?
    logger.info("[Paypal] incoming IPN")
    
    notify = Paypal::Notification.new(request.raw_post)
    pplog = PaypalLog.create
    pplog.log(notify)

    logger.info("[Paypal] (PaypalLog #{pplog.id})")

    if notify.acknowledge
      logger.info("[Paypal] (PaypalLog #{pplog.id}) IPN acknowledged: order #{notify.item_id} invoice #{notify.invoice} txn #{notify.transaction_id}")

      if notify.complete?
        logger.info("[Paypal] (PaypalLog #{pplog.id}) IPN for completion: order #{notify.item_id}")
        begin
          order = Order.find(notify.item_id)
        rescue ActiveRecord::RecordNotFound
          logger.error("[Paypal] (PaypalLog #{pplog.id}) Can't find order #{notify.item_id}")
          return
        end

        order.pay!

      else
        logger.info("[Paypal] (PaypalLog #{pplog.id}) IPN acknowledge but order isn't complete: order #{notify.item_id} payment_status #{notify.payment_status}")
      end

    else
      logger.error("[Paypal] (PaypalLog #{pplog.id}) IPN didn't acknowledge!")
    end
  end

end
