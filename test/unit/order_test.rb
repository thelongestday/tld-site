require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  should_have_many :tickets
  should_belong_to :owner
  should_not_allow_mass_assignment_of :owner
end
