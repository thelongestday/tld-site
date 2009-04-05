ActionController::Routing::Routes.draw do |map|
  map.comatose_admin
  map.comatose_root ''

  map.with_options :controller => 'punter' do |m|
    m.login  '/login',      :action => 'login'
    m.logout '/login',      :action => 'logout'
    m.user_edit   '/user/edit',  :action => 'edit'
    m.user_show   '/user/show',  :action => 'show'
    m.user_reset  '/user/reset', :action => 'reset'
    m.user_confirm '/u/:email/:token', :action => 'confirm'
  end

end
