

orders = Order.find_all_by_state('paid')
tickets = []
orders.each { |o| tickets << o.tickets }
tickets.flatten!

tickets = [ tickets.first ]

puts "tickets: #{tickets.length}"

tickets.each do |t|
  punter = t.punter
  puts "sending to #{punter.name_with_email}"
  begin
    if ENV['DO_IT']
       Notifier::deliver_all_over_jib(punter)
    else
      puts "not really"
    end
  rescue Exception => e
    puts "#{punter.name} borked: #{e}"
  end

end
