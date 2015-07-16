class AddDebtorIdToPayoneDebitPaymentPaymentSource < ActiveRecord::Migration
  def change
    add_column :spree_payone_debit_payment_payment_sources, :debtor_id, :string
  end
end
