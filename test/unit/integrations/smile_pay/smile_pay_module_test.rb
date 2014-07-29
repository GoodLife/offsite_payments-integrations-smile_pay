require 'test_helper'

class SmilePayModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of SmilePay::Notification, SmilePay.notification('name=cody')
  end
end
