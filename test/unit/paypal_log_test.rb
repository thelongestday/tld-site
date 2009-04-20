require 'test_helper'

class PaypalLogTest < ActiveSupport::TestCase
  should_belong_to :order

  context "receiving an IPN hash" do
    setup do
      @paypal_log = PaypalLog.create
      @ipn = Object.new
      @obj = Object.new
    end

    should "assign the required parameters to the log" do
      @ipn.expects(:params).with().at_least(1).returns(@obj)
      %w{ item_number txn_id receiver_id payer_id payment_status mc_gross mc_fee mc_currency invoice quantity }.each_with_index do |k, i|
        @obj.expects(:[]).with(k).returns(i)
      end  
      @paypal_log.log(@ipn)
      %w{ item_number txn_id receiver_id payer_id payment_status mc_gross mc_fee mc_currency invoice quantity }.each_with_index do |k, i|
        assert_equal @paypal_log[k], i
      end
    end
  end
end

