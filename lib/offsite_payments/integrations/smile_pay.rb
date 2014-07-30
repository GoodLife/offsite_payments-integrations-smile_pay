require "offsite_payments"
require_relative "smile_pay/version"

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module SmilePay

      #mattr_accessor :service_url
      mattr_accessor :production_url, :test_url

      self.production_url = 'https://ssl.smse.com.tw/ezpos/mtmk_utf.asp'
      self.test_url = 'https://ssl.smse.com.tw/ezpos_test/mtmk_utf.asp'

      def self.service_url
        case OffsitePayments.mode
        when :production
          self.production_url
        when :test
          self.test_url
        else
          raise StandardError, "Integration mode set to an invalid value: #{mode}"
        end
      end

      def self.notification(post)
        Notification.new(post)
      end

      def self.notification_confirmation_url
        'https://ssl.smse.com.tw/ezpos/roturl.asp'
      end

      class Helper < OffsitePayments::Helper
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

      class Notification < OffsitePayments::Notification
        attr_accessor :custom_user_confirmation_param #商家認證參數

        def complete?
          if ['A','D'].include?(params['Classif'])
            # Credit Card
            return params['Response_id'] == '1'
          else
            # No status except for non credit card payments
            true
          end
        end

        def item_id
          # 訂單號碼
          params['Data_id']
        end

        def transaction_id
          # Smile Pay 端訂單號碼
          params['Smseid']
        end

        # When was this payment received by the client.
        def received_at
          params['Process_date'] + params['Process_time']
        end

        def payer_email
          params['Email']
        end

        def receiver_email
          nil
        end

        def security_key
          # 驗證碼
          params['Mid_smilepay']
        end

        # the money amount we received in X.2 decimal.
        def gross
          ::Money.new(params['Amount'].to_i * 100, currency)
        end

        # Was this a test transaction?
        def test?
          OffsitePayments.mode == :test
        end

        def status
          params['Response_msg'] || 'Completed'
        end

        def currency
          case params['Moneytype']
          when 'TW'
            'TWD'
          when 'CN'
            'CNY'
          end
        end

        # SmilePay 沒有遠端驗證功能，
        # 而以認證碼代替
        def acknowledge
          if test? # SmilePay 客服回答測試環境時認證碼只會傳0
            true
          else
            # TODO 使用查詢功能實作 acknowledge
            params['Mid_smilepay'].to_i == calculated_mid_smile_key
          end
        end

        private

        def calculated_mid_smile_key
          b = "%08d" % (gross().dollars).to_i
          c = params['Smseid'][-4..-1].gsub(/\D/,'9')
          d = ( custom_user_confirmation_param() + b + c ).chars.to_a

          # 偶數位數字（從左算起）
          sum_even = d.values_at(* d.each_index.select(&:odd?)).compact.map(&:to_i).inject{|sum,x| sum + x }
          # 奇數位數字（從左算起）
          sum_odd = d.values_at(* d.each_index.select(&:even?)).compact.map(&:to_i).inject{|sum,x| sum + x }

          sum_even * 3 + sum_odd * 9
        end
      end
    end
  end
end
