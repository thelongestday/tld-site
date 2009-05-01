class Admin::PunterController < Admin::AdminController
    core_columns = [ :name, :email, :state, :has_paid_ticket?, :orders ]
    active_scaffold :punter do |config|
      config.actions = [ :list, :nested, :live_search ]
      config.columns = core_columns
      config.columns[:orders].association.reverse = :owner
      config.columns[:has_paid_ticket?].label = 'Has a paid ticket?'
      config.list.per_page = 100
    end
end
