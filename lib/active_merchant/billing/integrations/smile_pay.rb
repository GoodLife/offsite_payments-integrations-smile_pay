require File.dirname(__FILE__) + '/smile_pay/helper.rb'
require File.dirname(__FILE__) + '/smile_pay/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SmilePay

        #mattr_accessor :service_url
        mattr_accessor :production_url, :test_url

        self.production_url = 'https://ssl.smse.com.tw/ezpos/mtmk_utf.asp'
        self.test_url = 'https://ssl.smse.com.tw/ezpos_test/mtmk_utf.asp'

        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
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
      end
    end
  end
end
