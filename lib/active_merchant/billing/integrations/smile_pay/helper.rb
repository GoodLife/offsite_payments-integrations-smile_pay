module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SmilePay
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          def initialize(order, account, options = {})
            super

            # 參數碼
            add_field('Rvg2c', 1)
          end

          # 商家代號
          mapping :account, 'Dcvc'
          # 金額
          mapping :amount, 'Amount'
          # 訂單號碼
          mapping :order, 'Data_id'
          # 購買人(姓名改成單一欄位)
          mapping :customer, :name       => 'Pur_name',
                             :email      => 'Email',
                             :phone      => 'Tel_number',
                             :mobile_phone => 'Mobile_number' # Custom

          # 地址(改成單一欄位)
          mapping :shipping_address, 'Address'
          # 備註
          mapping :description, 'Remark'
          # 交易完成後要回送的位置
          mapping :notify_url, 'Roturl'
          # 回送處理情形
          mapping :notify_url_status, 'Roturl_status'


          ### 以下為本服務特有欄位 Custom Fields

          # 貨品名稱或貨品編號
          mapping :sku, 'Od_sob' 

          # 收費模式
          #   1. 線上刷卡
          #   2. ATM / 轉帳匯款繳費
          #   3. 超商代收
          #   4. 7-11 ibon
          #   5. 超商代收及 7-11 ibon
          #   6. FamiPort
          #   7. LifetET
          #   8. 匯款、超商及 7-11 自訂繳款單模式
          mapping :payment_method, 'Pay_zg'

          # 繳款截止期限
          mapping :deadline_date, 'Deadline_date'
          mapping :deadline_time, 'Deadline_time'

          # 語言模式
          mapping :language, 'Pay_gdry'

          #mapping :return_url, ''
          #mapping :cancel_return_url, ''
          #mapping :tax, ''
          #mapping :shipping, ''

          # 把 shipping address 轉成單一欄位
          def shipping_address(params = {})
            case params
            when Hash
              # TODO handle multi address input fields
              address = params.values.join(',')
            when String
              address = params
            end
            add_field(mappings[:shipping_address], address)
          end
        end
      end
    end
  end
end
