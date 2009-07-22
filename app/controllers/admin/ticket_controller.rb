class Admin::TicketController < Admin::AdminController
    core_columns = [ :id, :punter, :order ]
    active_scaffold :ticket do |config|
      config.actions = [ :list, :nested ]
      config.columns = core_columns
#      config.show.columns = core_columns + [ :orders ]
      config.action_links.add 'pdf', :label => 'pdf', :type => :record, :method => :get, :inline => false
    end


    def pdf
      ticket = Ticket.find(params[:id])
      if ticket.order.tickets.length == 1 && ticket.order.owner == ticket.punter
        filename = TicketPdf.pdf_for_order(ticket.order)
      else
        filename = TicketPdf.pdf_for_ticket(ticket)
      end
      send_file(filename, :type => 'appplication/pdf')
    end
end
