require 'prawn/core'
class TicketPdf

  def self.pdf_for_ticket(ticket, force = false)
    filename = "#{RAILS_ROOT}/private/t-#{ticket.id}.pdf"
    if !File.exists?(filename) || force
      order_text = "(one of #{ticket.order.tickets.length} invitations with this reference)"
      generate_pdf([ticket], filename, order_text)
    end
    filename
  end

  def self.pdf_for_order(order, force = false)
    filename = "#{RAILS_ROOT}/private/o-#{order.id}.pdf"
    if !File.exists?(filename) || force
      order_text = "(all invitations with this reference shown)"
      generate_pdf(order.tickets, filename, order_text)
    end
    filename
  end

  private

  def self.generate_pdf(tickets, filename, order_text)
    tld_backjib = "#{RAILS_ROOT}/private/tldbanner09.jpg"
    tld_map     = "#{RAILS_ROOT}/private/tld_map.png"

    Prawn::Document.generate(filename, :page_layout => :portrait, :page_size => 'A4') do
    
      bounding_box [ 10, 780 ], :width => 515, :height => 200  do
        stroke do
          line bounds.top_left, bounds.top_right
          line bounds.bottom_left, bounds.bottom_right
        end
        image tld_backjib, :at => [ 0, 190 ], :width => 510, :height => 180
        text 'Invitation', :size => 18, :at => [ 0, 180 ]
        text " ", :size => 8
        text "TLD ##{tickets.first.order.id}", :align => :right
        text order_text,  :align => :right, :size => 8

        bounding_box [ 10, 170 ], :width => 510, :height => 170 do

          y = 90 + ( 8 * tickets.length )
          tickets.each do |t|
        
            font 'Helvetica', :style => :bold
            text t.punter.name_with_email, :at => [ 20, y ], :size => 12
            font 'Courier', :style => :bold
            text "[ ##{t.id}/#{t.order.id} ]", :at => [ 390, y ], :size => 10
            y -= 20
          end
          
        end

        font 'Helvetica'
        text "We check the invite ids at the gate and the first person wins, so please don't give your mates copies of your invitation!", :at => [ 0, 10 ], :size => 8
      end
      
      bounding_box [ 10, 570 ], :width => 515, :height => 260 do
        stroke do
    #     line bounds.top_left, bounds.top_right
          line bounds.bottom_left, bounds.bottom_right
        end

        font 'Helvetica'
        text "This then is your invitation into The Longest Day 2/009, oh marvelling punter. Draw near and ye shall be wrecked.  You wonderful individual, you. Here are some do's and don'ts:", :size => 10

        bounding_box [ 5, 233 ], :width => 235 do
          font_size(8) do
            text " "
            text "Read and understand this", :style => :bold
            text " ", :size => 4
            text "* Food and drink are available on site, you don't need to bring any..."
            text " ", :size => 4
            text "* DON'T TELL ANYONE WHERE IT IS! Nothing will shut us down faster than gatecrashers. Besides, our security people are large, very large, and we take their muzzles off after dark."
            text " ", :size => 4
            text "* CLEAR UP AFTER YOURSELVES! Every year we get comments about how wonderful the location is, and every year it takes us until Thursday to clear up properly! DO NOT DROP YOUR STUFF WHERE YOU STAND! THERE WILL BE BINS, USE THEM! This year will see a MASSIVE anti-littering effort - if you are caught littering EXPECT ABJECT HUMILIATION!"
            text " ", :size => 4
            text "* All of the event's revenue goes into running this years event. Any accidental leftovers go to Medecins Sans Frontieres."
            text " ", :size => 4
            text "* No Fires. No fireworks. No Dogs. No BBQs. No sound systems."
            text " ", :size => 4
            text "* Anyone you bring with you must have a ticket in advance of the event, there are no on-the-day sales, 'cos, like last year, there won't be any tickets left! Tickets will be checked on the door by Big Men. You are responsible for your mates behavior. You are not responsible for the death of British manufacturing, and should really stop feeling guilty about that."
          end
        end

        bounding_box [ 250, 235 ] , :width => 235 do
          font_size(8) do
            text " "
            text "Things to bring", :style => :bold
            text " ", :size => 4
            text "* Money, moolah, dosh, wonga, cold hard cash for bar, eats and bribing your way into the VIP area"
            text " ", :size => 4
            text "* Baby wipes"
            text " ", :size => 4
            text "* Sun cream"
            text " ", :size => 4
            text "* Lots of water"
            text " ", :size => 4
            text "* Torch"
            text " ", :size => 4
            text "* Flags for the campsite, though we prefer ones that aren't national, team-shaped or discriminatory..."
            text " "
            text "Also", :style => :bold
            text " ", :size => 4
            text "* Don't forget that Saturday is fancy dress all day. Open theme. Surprise us!"
            text " ", :size => 4
            text "* Kids under 12 come free. Parents, bring a tenner if you'd like to chip into the bouncy castle hire."
            text " ", :size => 4
            text " * Should you wish to dress for Friday night the Lounge will be Victorian Salon Degeneracy."
          end
        end
        
      end

      bounding_box [ 10, 300 ], :width => 515, :height => 280 do
        stroke do
#          line bounds.top_left, bounds.top_right
#          line bounds.bottom_left, bounds.bottom_right
        end
        image tld_map, :at => [ 0, 270 ], :width => 515 

#       text "Where it’s at", :size => 10

        bounding_box [ 5, 295 ], :width => 220 do
          font_size(8) do
            text " "
            text "By car", :style => :bold
            text " ", :size =>2
            text "Go towards Brighton, pick up the A27 and drive towards Lewes."
            text " ", :size =>2
            text "From the first roundabout on the A27, turn right following signs for Kingston to Newhaven Road."
            text " ", :size =>2
            text "Turn right at the t-junction towards Rodmell. After Rodmell village turn right at Telscombe village sign."
            text " ", :size =>2
            text "At this point slow down and enjoy your arrival. BEWARE keep your speed down because this road's only one car wide with passing places (there have been accidents)."
            text " ", :size =>2
            text "Before the last hill you can see the Hetty field in the valley on the right. Take the sharp right turn at the bend at the top of that hill through gate."
            text " ", :size =>2
            text "(Don't be a twat by driving into Telscombe and disturbing the locals - it's a dead end anyway)."
            text " ", :size =>2
            text "Turning into our field through the open gate, it's a HARD right turn and please observe the traffic lights that we have put there. If it is RED, stop and wait, it means a vehicle is coming up the hill. Drive with care." 
            text " "

            text "By bus", :style => :bold
            text " ", :size => 2
            text "Renown Bus Service no.123 (Lewes-Newhaven). Alight at Southease bus shelter and then 2 mile uphill walk towards Telscombe, you’ll see us!"
            text " ", :size => 2

            text "By train", :style => :bold
            text " ", :size => 2
            text "Southease 2 1/2 miles. Please note long uphill walk to Telscombe. Lewes 7 miles, Brighton 7 miles"
            text " "
            text "We'll see you at registration and then the madness can begin. Have a safe journey everyone.", :style => :bold
          end
        end
      end


    end

  end
end
