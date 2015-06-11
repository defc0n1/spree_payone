# Provides implementation for Spree payment process logic for Spree::PaymentMethod::Payone::EWallet
module Spree::Payone
  module Provider
    module Payment
      class EWallet < Spree::Payone::Provider::Payment::Base

        # Sets initial data.
        def initialize(options)
          super(options)
          @wallet_type = options[:wallet_type]
        end

        # Proceses payment method authorize action.
        def authorize(money, e_wallet_source, payment_method_options = {})
          Spree::Payone::Logger.info "Authorize process started"

          request = Spree::Payone::Proxy::Request.new
          request.preauthorization_request

          set_initial_request_parameters(request)
          set_status_url_request_parameters(request, payment_method_options)
          set_e_wallet_request_parameters(request, e_wallet_source)
          set_amount_request_parameters(request, money, payment_method_options)
          set_order_request_parameters(request, payment_method_options)
          set_personal_data_request_parameters(request, payment_method_options)
          set_billing_request_parameters(request, payment_method_options)
          set_shipping_request_parameters(request, payment_method_options)

          response = process_request request, payment_method_options
          payment_provider_response response
        end

        # Proceses gateway purchase action.
        def purchase(money, e_wallet_source, payment_method_options = {})
          Spree::Payone::Logger.info "Purchase process started"

          request = Spree::Payone::Proxy::Request.new
          request.authorization_request

          set_initial_request_parameters(request)
          set_status_url_request_parameters(request, payment_method_options)
          set_e_wallet_request_parameters(request, e_wallet_source)
          set_amount_request_parameters(request, money, payment_method_options)
          set_order_request_parameters(request, payment_method_options)
          set_personal_data_request_parameters(request, payment_method_options)
          set_billing_request_parameters(request, payment_method_options)
          set_shipping_request_parameters(request, payment_method_options)

          response = process_request request, payment_method_options
          payment_provider_response response
        end

        # Proceses gateway capture action.
        def capture(money, response_code, payment_method_options = {})
          Spree::Payone::Logger.info "Capture process started"

          request = Spree::Payone::Proxy::Request.new
          request.capture_request

          set_initial_request_parameters(request)
          set_status_url_request_parameters(request, payment_method_options)
          set_amount_request_parameters(request, money, payment_method_options)
          set_payment_process_parameters(request, response_code)

          response = process_request request, payment_method_options
          payment_provider_response response
        end

        # Proceses gateway void action.
        def void(response_code, provider_source, gateway_options = {})
          Spree::Payone::Logger.info "Void process started"
          payment_payment_provider_successful_response
        end

        # Proceses gateway credit action.
        def credit(money, response_code, gateway_options = {})
          Spree::Payone::Logger.info "Credit process started"

          request = Spree::Payone::Proxy::Request.new
          request.debit_request
          set_initial_request_parameters(request)
          set_amount_request_parameters(request, '-' + money.to_s, gateway_options)
          set_payment_process_parameters(request, response_code)
          set_sequence_request_parameters(request, response_code)

          response = process_request request, payment_method_options
          payment_provider_response response
        end

        # Sets online bank transfer parameters.
        def set_e_wallet_request_parameters(request, e_wallet_source)
          request.e_wallet_clearingtype
          request.wallettype= wallet_type()
        end

        # Returns online bank transfer type.
        def wallet_type()
          type = Spree::Payone::Utils::WalletType.validate(@wallet_type)
          if type != nil
            return type
          else
            return ''
          end
        end
      end
    end
  end
end
