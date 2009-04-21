require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "invitation" do
    punter = Punter.new
    punter.expects(:email_with_name).returns('foo bar <foo@example.com>')
    punter.expects(:name).returns('foo bar')
    punter.expects(:authentication_token).returns('T0k3n')

    Notifier.deliver_invitation(punter, @expected.date)

    assert_sent_email do |email|
      email.to.include?('foo@example.com')
      email.from.include?('site@thelongestday.net')
      email.body.include?("You've been invited")
      email.body.include?('T0k3n')
    end
  end

  context "ticket sale" do
    setup do
      @pp = PaypalLog.generate { |pp| pp.txn_id = "732" }
      @order = Order.generate!
      @order.paypal_logs << @pp
      @p1 = Punter.generate!
      @t1 = Ticket.create
      @t1.update_attribute(:punter, @p1)
      @t1.update_attribute(:order, @order)
      @t2 = Ticket.create
      @t2.update_attribute(:punter, @order.owner)
      @t2.update_attribute(:order, @order)
      @order.save!
    end

    context "receipt" do
      setup { Notifier.deliver_ticket_sale_receipt(@order) }

      should "indicate the order details" do
        assert_sent_email do |email|
          email.body =~ /Order: #{@order.id} \(#{@order.uid}\)/
        end
      end

      should "indicate the number of tickets" do
        assert_sent_email do |email|
          email.body =~ /Number of tickets: 2/
        end
      end

      should "show the PayPal transaction id " do
        assert_sent_email do |email|
          email.body =~ /Paypal transaction: #{@pp.txn_id}/
        end
      end
    end

    context "message" do
      context "to ticket purchaser if they're the order owner" do
        setup { Notifier.deliver_ticket_sale_message(@order, @t2) }

        should "know they are the order owner" do
          assert_sent_email do |email|
            email.body =~ /Thanks for buying a ticket/
          end
        end
      end

      context "to ticket holder if they're not the order owner" do
        setup { Notifier.deliver_ticket_sale_message(@order, @t1) }

        should "know they are the order owner" do
          assert_sent_email do |email|
            email.body =~ /Lucky you!/
          end
        end
      end

      context "in any case" do
        setup { Notifier.deliver_ticket_sale_message(@order, @t1) }

        should "indicate ticket details" do
          assert_sent_email do |email|
            email.body =~ /Order:\s+#{@order.id} \(#{@order.uid}\)/
            email.body =~ /Ticket:\s+#{@t1.id}/
          end
        end
      end
    end
  end
end
