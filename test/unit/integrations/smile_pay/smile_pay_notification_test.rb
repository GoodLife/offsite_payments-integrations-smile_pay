require 'test_helper'

class SmilePayNotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @smile_pay = SmilePay::Notification.new(http_raw_data)
    @smile_pay.custom_user_confirmation_param = '1234'
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
    OffsitePayments.mode = :production
    assert @smile_pay.acknowledge
    OffsitePayments.mode = :test
  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @smile_pay.respond_to?(:acknowledge)
  end

  def test_calculated_mid_smile_key
    assert @smile_pay.send(:calculated_mid_smile_key), '213'
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
      Mid_smilepay=213
    }.join('&')
  end
end
