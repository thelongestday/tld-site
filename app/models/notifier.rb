class Notifier < ActionMailer::Base
  
  def invitation(punter, sent_at = Time.now)
    subject    "[TLD] You've been invited to #{Site::Config.event.name}"
    recipients punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    sent_at
    
    body       :invitee => punter
  end

  def ticket_sale_receipt(order)
    subject    "[TLD] Your receipt for #{Site::Config.event.name} tickets"
    recipients order.owner.email_with_name
    from       'site@thelongestday.net'
    sent_on    Time.now

    body       :order => order
  end

  def ticket_sale_message(order, ticket)
    subject    "[TLD] Your ticket for #{Site::Config.event.name}"
    recipients ticket.punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    Time.now

    body       :order => order, :ticket => ticket
  end

end
