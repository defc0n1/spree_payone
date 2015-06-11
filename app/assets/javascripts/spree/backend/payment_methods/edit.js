$(function() {
  function onPaymentMethodGlobalSettings(Enabledmethod_name) {
    $('label[for=' + method_name + '_preferred_merchant_id]').hide();
    $('#' + method_name + '_preferred_merchant_id').hide();
    $('#' + method_name + '_preferred_merchant_id').next('br').hide();

    $('label[for=' + method_name + '_preferred_payment_portal_id]').hide();
    $('#' + method_name + '_preferred_payment_portal_id').hide();
    $('#' + method_name + '_preferred_payment_portal_id').next('br').hide();

    $('label[for=' + method_name + '_preferred_payment_portal_key]').hide();
    $('#' + method_name + '_preferred_payment_portal_key').hide();
    $('#' + method_name + '_preferred_payment_portal_key').next('br').hide();

    $('label[for=' + method_name + '_preferred_sub_account_id]').hide();
    $('#' + method_name + '_preferred_sub_account_id').hide();
    $('#' + method_name + '_preferred_sub_account_id').next('br').hide();

    $('label[for=' + method_name + '_preferred_test_mode]').hide();
    $('#' + method_name + '_preferred_test_mode').hide();
    $('#' + method_name + '_preferred_test_mode').next('br').hide();
  }

  function onPaymentMethodGlobalSettingsDisabled(method_name) {
    $('label[for=' + method_name + '_preferred_merchant_id]').show();
    $('#' + method_name + '_preferred_merchant_id').show();
    $('#' + method_name + '_preferred_merchant_id').next('br').show();

    $('label[for=' + method_name + '_preferred_payment_portal_id]').show();
    $('#' + method_name + '_preferred_payment_portal_id').show();
    $('#' + method_name + '_preferred_payment_portal_id').next('br').show();

    $('label[for=' + method_name + '_preferred_payment_portal_key]').show();
    $('#' + method_name + '_preferred_payment_portal_key').show();
    $('#' + method_name + '_preferred_payment_portal_key').next('br').show();

    $('label[for=' + method_name + '_preferred_sub_account_id]').show();
    $('#' + method_name + '_preferred_sub_account_id').show();
    $('#' + method_name + '_preferred_sub_account_id').next('br').show();

    $('label[for=' + method_name + '_preferred_test_mode]').show();
    $('#' + method_name + '_preferred_test_mode').show();
    $('#' + method_name + '_preferred_test_mode').next('br').show();
  }

  function registerPaymentMethodGlobalSettingsSwitching(method_name) {
    $('#' + method_name + '_preferred_use_global_account_settings').change(function() {
        // in jQuery 1.6 or newer we have to use $(this).prop('checked') instead of $(this).attr('checked')
        if ($(this).prop('checked')) {
          onPaymentMethodGlobalSettingsEnabled(method_name);
        }
        else {
          onPaymentMethodGlobalSettingsDisabled(method_name);
        }
    });
    $('#' + method_name + '_preferred_use_global_account_settings').change();
  }

  registerPaymentMethodGlobalSettingsSwitching('gateway_payone_credit_card');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_online_bank_transfer');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_debit_payment');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_e_wallet');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_cash_on_delivery');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_cash_in_advance');
  registerPaymentMethodGlobalSettingsSwitching('payment_method_payone_invoice');
});
