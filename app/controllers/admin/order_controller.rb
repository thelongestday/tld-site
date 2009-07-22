class Admin::OrderController < Admin::AdminController
    core_columns = [ :id, :uid, :owner, :tickets, :children, :state ]
    active_scaffold :order do |config|
      config.actions = [ :list, :nested ]
      config.columns = core_columns
      config.action_links.add 'pdf', :label => 'pdf', :type => :record, :method => :get, :inline => false
    end


    def pdf
      @order = Order.find(params[:id])
      filename = TicketPdf.pdf_for_order(@order)
      send_file(filename, :type => 'appplication/pdf')
    end

end
