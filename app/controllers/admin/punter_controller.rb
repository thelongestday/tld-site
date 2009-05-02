class Admin::PunterController < Admin::AdminController
    protect_from_forgery :only => [:create, :update, :delete]

    core_columns = [ :id, :name, :email, :state, :has_paid_ticket?, :has_flailed_signup?, :orders ]
    active_scaffold :punter do |config|
      config.actions = [ :list, :nested, :live_search ]
      config.columns = core_columns
      config.columns[:orders].association.reverse = :owner
      config.columns[:has_paid_ticket?].label = 'Has a paid ticket?'
      config.columns[:has_paid_ticket?].form_ui = :checkbox
      config.columns[:has_flailed_signup?].form_ui = :checkbox
      config.list.per_page = 100
      config.action_links.add 'reset', :label => 'reset / re-invite', :type => :record, :method => :post, :confirm => "Sigh - more flail eh?", :inline => true, :position => :after
    end

    def reset
      return if request.get?
      @punter = Punter.find_by_id(params[:id])
      @punter.reset!
      render :text => 'OK, invite resent'
    end
end
