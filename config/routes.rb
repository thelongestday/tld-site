ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'punter' do |m|
    m.login  '/login',      :action => 'login'
    m.logout '/logout',     :action => 'logout'
    m.user_edit   '/user/edit',   :action => 'edit'
    m.user_show   '/user/show',   :action => 'show'
    m.user_update '/user/update', :action => 'update'
    m.user_reset  '/user/reset',  :action => 'reset'
    m.user_reject '/user/reject', :action => 'reject'
    m.user_confirm '/u/:token',   :action => 'confirm'
    m.user_invite '/user/invite', :action => 'invite'
  end

  map.comatose_admin
  map.comatose_root 'invitees',  :index => 'invitees',             :layout => 'tld'
  map.comatose_root 'attendees', :index => 'attendees',            :layout => 'tld'
  map.comatose_root '',          :index => 'the-longest-day-2009', :layout => 'tld'

end
