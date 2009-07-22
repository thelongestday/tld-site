class Notifier < ActionMailer::Base
  
  def invitation(punter, sent_at = Time.now)
    subject    "[TLD] You've been invited to #{Site::Config.event.name}"
    recipients punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    sent_at
    
    body       :invitee => punter
  end

  def hassle(punter, sent_at = Time.now)

    subject    "[TLD] That buy-a-ticket-nudge you've been waiting for"
    recipients punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    sent_at
    
    body       :invitee => punter
  end

  def reset(punter, sent_at = Time.now)
    subject    "[TLD] Password reset"
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

  def ticket_pdf_pickup(ticket)
    subject    "[TLD] Your ticket for #{Site::Config.event.name}"
    recipients ticket.punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    Time.now

    body       :ticket => ticket
    filename = TicketPdf::pdf_for_ticket(ticket)
    attachment :content_type => "application/pdf", :body => File.read(filename), :filename => File.basename(filename)
    
  end

  def order_pdf_pickup(order)
    subject    "[TLD] Your order for #{Site::Config.event.name} tickets"
    recipients  order.owner.email_with_name
    from       'site@thelongestday.net'
    sent_on    Time.now

    body       :order => order
    filename = TicketPdf::pdf_for_ticket(ticket)
    attachment :content_type => "application/pdf", :body => File.read(filename), :filename => File.basename(filename)
  end
end
