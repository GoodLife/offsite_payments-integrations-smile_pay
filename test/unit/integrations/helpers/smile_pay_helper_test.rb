require 'test_helper'

class SmilePayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = SmilePay::Helper.new('order-500','0000', :amount => 500, :currency => 'TWD')
  end

  def test_basic_helper_fields
    assert_field 'Ddvc', '0000'

    assert_field 'Amount', '500'
    assert_field 'Data_id', 'order-500'
  end

  def test_customer_fields
    @helper.customer :name => 'Cody Fauser', :email => 'cody@example.com'
    assert_field 'Pur_name', 'Cody Fauser'
    assert_field 'Email', 'cody@example.com'
  end

  def test_address_mapping
    @helper.shipping_address 'address'
    assert_field 'Address', 'address'
=begin
    @helper.shipping_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_field 'shipping_address', '1 My Street,,Yorkshire,LS2 7EE,CA'
=end
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

=begin
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
=end
end
