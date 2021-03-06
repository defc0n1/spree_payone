# Spree gateway which covers PAYONE credit card operations.
#
# Uses ::Spree::Payone::Provider::Payment::CreditCard for standard
# Spree gateway action implementations.
module Spree
  class Gateway::Payone::CreditCard < Gateway

    # Gateway preferences
    preference :use_global_account_settings, :boolean, :default => true
    preference :merchant_id, :string
    preference :payment_portal_id, :string
    preference :payment_portal_key, :string
    preference :sub_account_id, :string
    preference :test_mode, :boolean, :default => true
    preference :currency_code, :string, :default => 'EUR'
    preference :credit_card_types, :string, :default => 'V'

    # delete the server from preferences, we set it in options
    after_initialize do
      preferences.delete(:server)
    end

    # Returns provider class responsible for Spree gateway action implementations.
    def provider_class
      ::Spree::Payone::Provider::Payment::CreditCard
    end

    # Returns payment source class.
    def payment_source_class
      CreditCard
    end

    # Returns profiles storage support (PAYONE on-site storage not supported).
    def payment_profiles_supported?
      true
    end

    def create_profile(payment)
      creditcard = payment.source
      method = payment.payment_method

      # Process creditcardcheck and retrieve profile id
      if creditcard.gateway_customer_profile_id.nil?
        creditCardCheck = ::Spree::Payone::Provider::Check::CreditCard.new(method.options)
        response = creditCardCheck.process payment.source, {}

        if response.valid_status?
          profile_id = response.pseudocardpan
          # Assign attributes one by one ("Can't mass-assign protected attributes" exception)
          # for update_attributes which is currently deprecated
          creditcard.gateway_customer_profile_id= profile_id
          creditcard.gateway_payment_profile_id= 0
          creditcard.save
        else
          raise Core::GatewayError.new(I18n.t(:payone_credit_card_check_failed, scope: 'payone'))
        end
      end
    end

    # Returns PAYONE gateway options. Internally sets :server which
    # depends on :test_mode.
    def options
      options_map = super
      options_map[:server] = 'test'
      if options_map.has_key?(:test_mode) and options_map[:test_mode] == false
        options_map[:server] = 'active'
      end
      options_map
    end

    # Redefines method_type which allows to load correct partial template
    # for gateway (does not load default _gateway.html.erb template).
    def method_type
      'payone_creditcard'
    end
  end
end
