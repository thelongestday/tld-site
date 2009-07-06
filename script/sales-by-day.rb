
# script/runner script/sales-by-day.rb  > app/views/admin/admin/_graph.html.erb

orders = Order.find_all_by_state('paid', :include => :tickets).sort { |x,y| x.updated_at <=> y.updated_at }

start  = orders.first.updated_at.to_date
finish = orders.last.updated_at.to_date
today  = Date.today

sales = Sale.find(:all, :order => 'date ASC')
if sales.empty?
  date = start
else
  date = sales.last.date + 1.day
end

STDERR.puts "Dates: #{start} -> #{finish}"
STDERR.puts "Refreshing from #{date}"

while date <= finish
  day_orders = orders.find_all { |o| o.updated_at.to_date == date }
  day_tickets = day_orders.inject(0) { |t,o| t += o.tickets.length }
  puts "#{date} : #{day_tickets}"
  Sale.create!(:date => date, :tickets => day_tickets)
  date += 1.day
end

xl = sprintf("%02d/%02d", start.day, start.month)
xr = sprintf("%02d/%02d", finish.day, finish.month)
sales = Sale.find(:all, :order => 'date ASC')
t = sales.inject(0) { |t, s| t += s.tickets }
n = 0

url = "http://chart.apis.google.com/chart?cht=lc&chtt=Ticket+sales+by+day&chxt=x,y&chxl=0:|#{xl}|#{xr}|1:|0|#{t}&chs=800x200&chd=t:"
url += sales.map { |s| n += s.tickets ; (100 * n/t).to_i }.join(',')

puts %Q{<img src="#{url}" alt="disraeli"/>}
