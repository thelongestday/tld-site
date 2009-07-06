orders = Order.find_all_by_state('paid', :include => :tickets).sort { |x,y| x.updated_at <=> y.updated_at }

start  = orders.first.updated_at.to_date
finish = orders.last.updated_at.to_date

puts "Dates: #{start} -> #{finish}"

date = start

while date <= finish
  day_orders = orders.find_all { |o| o.updated_at.to_date == date }
  day_tickets = day_orders.inject(0) { |t,o| t += o.tickets.length }
  puts "#{date} : #{day_tickets}"
  date += 1.day
end
