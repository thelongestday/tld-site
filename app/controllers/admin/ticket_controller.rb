class Admin::TicketController < Admin::AdminController
    core_columns = [ :id, :punter, :order ]
    active_scaffold :ticket do |config|
      config.actions = [ :list, :nested ]
      config.columns = core_columns
#      config.show.columns = core_columns + [ :orders ]
    end
end
