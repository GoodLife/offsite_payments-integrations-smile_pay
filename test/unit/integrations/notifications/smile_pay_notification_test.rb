require 'test_helper'

class SmilePayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @smile_pay = SmilePay::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @smile_pay.complete?
    assert_equal "Completed", @smile_pay.status
    assert_equal "12_24_123", @smile_pay.transaction_id
    assert_equal "888", @smile_pay.item_id
    assert_equal Money.new(532 * 100,'TWD'), @smile_pay.gross
    assert_equal "TWD", @smile_pay.currency
    assert_equal "20130310140000", @smile_pay.received_at
    assert @smile_pay.test?
  end

  def test_compositions
    assert_equal Money.new(532 * 100, 'TWD'), @smile_pay.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @smile_pay.respond_to?(:acknowledge)
  end

  def test_calculated_mid_smile_key
    assert @smile_pay.send(:calculated_mid_smile_key, '1234'), '213'
  end

  private
  def http_raw_data
    %W{
      Amount=532
      Smseid=12_24_123
      Data_id=888
      Moneytype=TW
      Process_date=20130310
      Process_time=140000
    }.join('&')
  end
end