class AddBankDetailsToGeneralSettings < ActiveRecord::Migration[7.0]
  def change
    change_table :general_settings, bulk: true do |t|
      t.string :bank_account_name
      t.string :bank_account_number
      t.string :bank_sort_code
      t.string :bank_iban
      t.text   :bank_instructions
      t.string :bank_reference_hint
    end
  end
end

