
orders = Order.find_all_by_state_and_tickets_sent('paid', false)

puts "#{orders.length} orders to send"

orders.each do |o|
  begin
    if o.is_just_for_owner?
      puts "#{o.id} sole owner #{o.owner.name_with_email} == #{o.tickets.first.punter.name_with_email} [ #{o.tickets.length} ]"
      # Notifier::deliver_order_pdf_pickup(o)
    else
      puts "#{o.id} owner is #{o.owner.name_with_email}"
      # Notifier::deliver_order_pdf_pickup(o)
      o.tickets.each do |t|
        puts "#{o.id} ticket #{t.id} for #{t.punter.name_with_email}"
        # Notifier::deliver_ticket_pdf_pickup(t)
      end
    end

  o.update_attribute(:tickets_sent, true)

  rescue Exception => e
    puts "#{o.id} flailed #{e}"
  end

end



