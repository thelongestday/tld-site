module ApplicationHelper
  include Paypal::Helpers

  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end
end
