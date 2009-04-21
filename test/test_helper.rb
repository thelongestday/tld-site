ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'action_view/test_case'

class ActiveSupport::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

end

class ActionView::TestCase
  class TestController < ActionController::Base
    attr_accessor :request, :response, :params
 
    def initialize
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      
      # TestCase doesn't have context of a current url so cheat a bit
      @params = {}
      send(:initialize_current_url)
    end
  end
end


# get around Ticket's paranoic protected attributes
def create_ticket(opts)
  t = Ticket.create
  t.update_attribute(:event, Site::Config.event)
  t.update_attribute(:cost,  Site::Config.event.cost)
  t.update_attribute(:punter, opts[:punter] || Punter.generate!)
  t.update_attribute(:order,  opts[:order]  || Order.generate!)
  t
end
