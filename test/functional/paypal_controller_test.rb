require 'test_helper'

class PaypalControllerTest < ActionController::TestCase
  context "Receiving IPN" do
    setup do
      @ppn = stub_everything('paypal notification')
      Paypal::Notification.expects(:new).with(@controller.request.raw_post).returns(@ppn)
      @ppl = PaypalLog.new
      PaypalLog.expects(:create).returns(@ppl)
    end

    should "log it" do
      @ppl.expects(:log).with(@ppn)
      @ppn.expects(:acknowledge).returns(false)
      post :ipn
    end

    should "not look for an order if it acknowledges but isn't complete" do
      @ppl.expects(:log).with(@ppn)
      @ppn.expects(:acknowledge).returns(true)
      @ppn.expects(:complete?).returns(false)
      Order.expects(:find).never
      post :ipn
    end

    context "with an acknowledged, complete order" do
      setup do
        @ppl.expects(:log).with(@ppn)
        @ppn.expects(:acknowledge).returns(true)
        @ppn.expects(:complete?).returns(true)
        @ppn.expects(:item_id).at_least(1).returns(732)
      end

      should "find the order" do
        o = stub_everything('order')
        Order.expects(:find).with(732).returns(o)
        post :ipn
      end

      should "mark that order paid" do
        o = Order.generate!
        o.confirm!
        o.expects(:pay!)
        Order.expects(:find).with(732).returns(o)
        post :ipn
      end
    end
  end
end
