
orders = Order.find_all_by_state_and_tickets_sent('paid', false)

if ENV['ORDERS']
  trim = ENV['ORDERS'].split(/,/).map { |o| o.to_i }
  orders = orders.find_all { |o| trim.include?(o.id) }
end

puts "#{orders.length} orders to send"

orders.each do |o|
  begin
    if o.is_just_for_owner?
      puts "#{o.id} sole owner #{o.owner.name_with_email} == #{o.tickets.first.punter.name_with_email} [ #{o.tickets.length} ]"
      if ENV['DO_IT']
        Notifier::deliver_order_pdf_pickup(o)
      end
    else
      puts "#{o.id} owner is #{o.owner.name_with_email}"
      if ENV['DO_IT']
        Notifier::deliver_order_pdf_pickup(o)
      end
      o.tickets.each do |t|
        puts "#{o.id} ticket #{t.id} for #{t.punter.name_with_email}"
        if ENV['DO_IT']
          Notifier::deliver_ticket_pdf_pickup(t)
        end
      end
    end

    if ENV['DO_IT']
      o.update_attribute(:tickets_sent, true)
    end

  rescue Exception => e
    puts "#{o.id} flailed #{e}"
  end

end




