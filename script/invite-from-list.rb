while email = gets
  email.chomp!
  begin
    Punter.invite_without_name(email)
    puts "#{email} OK"
  rescue ActiveRecord::RecordInvalid => e
    puts "#{email} INV: #{e}"
  rescue Exception => e
    puts "#{email} NOK: #{e}" 
  end
  sleep 1
end
