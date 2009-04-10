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
  end

  map.comatose_admin
  map.comatose_root '', :layout=> 'tld'

end
