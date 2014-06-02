require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SmilePay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          attr_accessor :custom_user_confirmation_param #商家認證參數

          # TODO credit card
          def complete?
            # No status except for credit card
            true
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
            ActiveMerchant::Billing::Base.integration_mode == :test
          end

          def status
            'Completed'
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

=begin
          # Acknowledge the transaction to SmilePay. This method has to be called after a new
          # apc arrives. SmilePay will verify that all the information we received are correct and will return a
          # ok or a fail.
          #
          # Example:
          #
          #   def ipn
          #     notify = SmilePayNotification.new(request.raw_post)
          #
          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge
            payload = raw

            uri = URI.parse(SmilePay.notification_confirmation_url)

            request = Net::HTTP::Post.new(uri.path)

            request['Content-Length'] = "#{payload.size}"
            request['User-Agent'] = "Active Merchant -- http://home.leetsoft.com/am"
            request['Content-Type'] = "application/x-www-form-urlencoded"

            http = Net::HTTP.new(uri.host, uri.port)
            http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
            http.use_ssl        = true

            response = http.request(request, payload)

            # Replace with the appropriate codes
            raise StandardError.new("Faulty SmilePay result: #{response.body}") unless ["AUTHORISED", "DECLINED"].include?(response.body)
            response.body == "AUTHORISED"
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
=end
        end
      end
    end
  end
end
