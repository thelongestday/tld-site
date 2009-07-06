ActionController::Routing::Routes.draw do |map|
  map.resources :orders, :member => { :confirm => :post, :ack => :any, :children => :any }

  map.with_options :controller => 'punter' do |m|
    m.login  '/login',      :action => 'login'
    m.logout '/logout',     :action => 'logout'
    m.user_edit   '/user/edit',   :action => 'edit'
    m.user_show   '/you',         :action => 'show'
    m.user_signup '/signup',      :action => 'signup'
    m.invite_self '/user/invite_self', :action => 'invite_self'
    m.user_update '/user/update', :action => 'update'
    m.user_reset  '/user/reset',  :action => 'reset'
    m.user_reject '/user/reject', :action => 'reject'
    m.user_confirm '/u/:token',   :action => 'confirm'
    m.user_confirm_frame '/v/:token',   :action => 'confirm_frame'
    m.user_invite '/user/invite', :action => 'invite'
    m.signup_ack '/signup/ack',   :action => 'signup_ack'
  end

  map.with_options :controller => 'paypal' do |m|
    m.paypal_ipn '/paypal/ipn', :action => 'ipn'
  end

  map.connect '/tld_admin', :controller => 'admin/admin', :action => 'index'
  map.connect '/tld_admin/tickets', :controller => 'admin/admin', :action => 'tickets'
  map.connect '/tld_admin/shame', :controller => 'admin/admin', :action => 'shame'
  map.connect '/tld_admin/punter/:action', :controller => "admin/punter"
  map.connect '/tld_admin/order/:action', :controller => "admin/order"
  map.connect '/tld_admin/ticket/:action', :controller => "admin/ticket"
  map.connect '/tld_admin/paypal_log/:action', :controller => "admin/paypal_log"

  map.comatose_admin
  map.comatose_root 'invitees',  :index => 'invitees',             :layout => 'tld'
  map.comatose_root 'attendees', :index => 'attendees',            :layout => 'tld'
  map.comatose_root '',          :index => 'the-longest-day-2009', :layout => 'tld'


end
