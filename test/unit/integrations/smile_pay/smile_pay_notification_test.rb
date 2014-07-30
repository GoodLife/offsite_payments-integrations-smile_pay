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

  def test_credit_card_notification
    raw_post = "Response_id=1&Moneytype=TW&Pur_name=&Classif=A&payment=3100&Od_sob=212515&customer_id=212515&billto=SmilePay&last_order=212515&customer_id=212515&Result=1&Purchamt=3100&Amount=3100&Data_id=212515&Process_date=2014%2F7%2F30&Process_time=15%3A02%3A7&Auth_code=123456&Tel_number=122141244&Mobile_number=122141244&Address=&Email=test%40example.com&Invoice_num=&Errdesc=&Smseid=7_30_1_1074870&Mid_smilepay=315&Remark=&Response_msg=%E5%B7%B2%E6%8E%88%E6%AC%8A"
    @smile_pay = SmilePay::Notification.new(raw_post)
    assert_equal true, @smile_pay.complete?
    assert_equal '已授權', @smile_pay.status
  end

  def test_credit_card_notification_error
    raw_post = "Response_id=0&Moneytype=TW&Pur_name=&Classif=A&payment=0&Od_sob=212512&customer_id=212512&billto=SmilePay&last_order=212512&customer_id=212512&Result=1&Purchamt=6200&Amount=0&Data_id=212512&Process_date=2014%2F7%2F30&Process_time=13%3A42%3A58&Auth_code=&Tel_number=122141244&Mobile_number=122141244&Address=&Email=test%40example.com&Invoice_num=&Errdesc=%288%3A57%29%E6%8B%92%E7%B5%95%E6%8C%81%E5%8D%A1%E8%80%85%E9%80%B2%E8%A1%8C%E8%A9%B2%E7%B6%B2%E8%B7%AF%E4%BA%A4%E6%98%93&Smseid=7_30_1_1074867&Mid_smilepay=357&Remark=&Response_msg=%E6%8E%88%E6%AC%8A%E5%A4%B1%E6%95%97"
    @smile_pay = SmilePay::Notification.new(raw_post)
    assert_equal false, @smile_pay.complete?
    assert_equal '授權失敗', @smile_pay.status
  end

  def test_ibon
    raw_post = "Classif=E&Od_sob=216&Data_id=216&Payment_no=21693575306&Process_date=2014/7/20&Process_time=08:19:45&Moneytype=TW&Purchamt=1570&Amount=1570&Response_id=1&Pur_name=&Tel_number=098800000&Mobile_number=098800000&Address=&Email=test@example.com&Invoice_num=&Smseid=7_19_1_0000000&LastPan=&Mid_smilepay=320&Auth_code=99999999999&Foreign=&Veirify_number=&Remark="
    @smile_pay = SmilePay::Notification.new(raw_post)
    assert_equal true, @smile_pay.complete?
    assert_equal 'Completed', @smile_pay.status
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
