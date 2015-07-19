module Spree
  module Admin
    PaymentsController.class_eval do
      def create
        @payment = @order.payments.build(object_params)
        @payment.admin_created= true

        if payone_credit_card? && known_card_in_params?(:payone_card)
          @payment.source = CreditCard.find_by_id(params[:payone_card])
        elsif spree_gateway? && known_card_in_params?(:card)
          @payment.source = CreditCard.find_by_id(params[:card])
        end

        begin
          if @payment.save
            if @order.completed?
              @payment.process!

              if @payment.redirect_url.present?
                probably_redundant_attribute_setter
                redirect_to @payment.redirect_url and return
              end

              flash.notice = flash_message_for(@payment, :successfully_created)

              redirect_to admin_order_payments_path(@order)
            else
              # This is the first payment (admin created order)
              until @order.completed?
                @order.next!

                if @order.redirect_required?
                  @order.payments.each do |payment|
                    if payment.redirect_url.present?
                      probably_redundant_attribute_setter
                      redirect_to payment.redirect_url and return
                    end
                  end
                end
              end
              flash.notice = t(:new_order_completed)
              redirect_to edit_admin_order_url(@order)
            end
          else
            redirect_to admin_order_payments_path(@order)
          end

        rescue Spree::Core::GatewayError => e
          flash[:error] = "#{e.message}"
          redirect_to new_admin_order_payment_path(@order)
        end
      end

      def payone_success
        token = params[:token]
        action_token = params[:action_token]
        payment_id = @payment.id
        request_history_entries =
          ::Spree::PayoneRequestHistoryEntry.where(
            :payment_id => payment_id, :success_token => action_token)

        if @order.token == token && request_history_entries.present? && @payment.response_code == request_history_entries.first.txid
          request_history_entry = request_history_entries.first
          if request_history_entry.request_type == "authorization"
            @payment.complete!
          else
            @payment.pend!
          end
          request_history_entry.overall_status = true
          request_history_entry.save

          if @order.completed?
            flash.notice = flash_message_for(@payment, :successfully_created)
            redirect_to admin_order_payments_path(@order) and return
          else
            # We must process changes manually
            @order.state= :complete
            @order.finalize!
            @order.update!

            flash.notice = t(:new_order_completed)
            redirect_to admin_order_url(@order) and return
          end
        end

        flash[:error] = t(:payment_processing_failed)
        redirect_to new_admin_order_payment_path(@order)
      end

      def payone_error
        token = params[:token]
        action_token = params[:action_token]
        payment_id = @payment.id
        request_history_entries =
          ::Spree::PayoneRequestHistoryEntry.where(
            :payment_id => payment_id, :error_token => action_token)

        if @order.token == token && request_history_entries.present? && @payment.response_code == request_history_entries.first.txid
          @payment.failure
        end

        flash[:error] = t(:payment_processing_failed)
        redirect_to new_admin_order_payment_path(@order)
      end

      def payone_back
        token = params[:token]
        action_token = params[:action_token]
        payment_id = @payment.id
        request_history_entries =
          ::Spree::PayoneRequestHistoryEntry.where(
            :payment_id => payment_id, :back_token => action_token)

        if @order.token == token && request_history_entries.present? && @payment.response_code == request_history_entries.first.txid
          @payment.failure
        end

        flash[:error] = t(:payment_processing_canceled, scope: 'payone')
        redirect_to new_admin_order_payment_path(@order)
      end

      private

      def known_card_in_params?(card_type)
        payment_profiles_supported? && params[card_type].present? and params[card_type] != 'new'
      end

      def payment_profiles_supported?
        @payment.payment_method.payment_profiles_supported?
      end

      def spree_gateway?
        @payment.payment_method.is_a?(Spree::Gateway)
      end

      def payone_credit_card?
        @payment.payment_method.is_a?(Spree::Gateway::Payone::CreditCard)
      end

      def probably_redundant_attribute_setter
        attrs = @payment.attributes
        @payment.reload
        attrs.each do |key, value|
          @payment.update_attribute key, value
        end
      end
    end
  end
end
