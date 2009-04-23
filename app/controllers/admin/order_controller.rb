class Admin::OrderController < Admin::AdminController
    core_columns = [ :id, :uid, :owner, :tickets, :state ]
    active_scaffold :order do |config|
      config.actions = [ :list, :nested ]
      config.columns = core_columns
#      config.show.columns = core_columns + [ :orders ]
    end
end
