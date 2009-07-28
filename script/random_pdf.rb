require 'prawn/core'

Prawn::Document.generate("#{RAILS_ROOT}/private/alternative_route.pdf", :page_layout => :landscape, :page_size => 'A4') do 
  text "We've found out (thanks Wayne!) that the road that goes from the A27 roundabout by Lewes and through the village of Kingston is now closed for road works and will be for several weeks."
  text "Don't worry, check out this new route instead."
  text " "
  image "#{RAILS_ROOT}/private/alternative_route.jpg", :width => 500
  text " "
  text "Instead of turning off at the Kingston roundabout, stay on the A27 until Beddingham where we turn onto the A26, which we follow until the right turn to Southease Railway Station. From there we follow road through Southease village to main road (T junction). Turn right and take first left towards Telscombe."
end

