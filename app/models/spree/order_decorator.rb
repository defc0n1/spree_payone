module Spree
  Order.class_eval do
    attr_accessor :redirect_required

    def blocked_payment_method_types_array
      blocked_payment_method_types.to_s.split(/,/)
    end

    def available_payment_methods(display_on = nil)
      blocked = blocked_payment_method_types_array
      PaymentMethod
        .where('type not in (?)', blocked.empty? ? '' : blocked)
        .all(display_on)
    end

    def available_payment_methods
      blocked = blocked_payment_method_types_array
      @available_payment_methods ||=
        PaymentMethod
        .where('type not in (?)', blocked.empty? ? '' : blocked)
        .available_on_front_end
    end

    def redirect_required?
      self.redirect_required
    end

    insert_checkout_step :payment_redirect, :after => :complete

    Order.state_machines[:state].before_transition :to => :complete do |order|
      begin
        # Decorate the before_transaction and add steps to original order.process_payments!
        order.redirect_required = false
        order.payments.each do |payment|
          if !payment.redirect_url.to_s.empty?
            order.redirect_required = true
            break
          end
        end

        # Return true to inform that transition succeeded
        true
      rescue Core::GatewayError
        !!Spree::Config[:allow_checkout_on_gateway_error]
      end
    end

    Order.state_machines[:state].before_transition :to => :payment_redirect do |order|
      order.completed_at = ''
    end
  end
end
