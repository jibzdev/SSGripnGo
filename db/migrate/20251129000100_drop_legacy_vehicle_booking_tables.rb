class DropLegacyVehicleBookingTables < ActiveRecord::Migration[7.0]
  def up
    if foreign_key_exists?(:payments, :bookings)
      remove_foreign_key :payments, :bookings
    end

    drop_table(:group_service_prices) if table_exists?(:group_service_prices)
    drop_table(:bookings) if table_exists?(:bookings)
    drop_table(:vehicles) if table_exists?(:vehicles)
    drop_table(:vehicle_groups) if table_exists?(:vehicle_groups)
    drop_table(:vehicle_data) if table_exists?(:vehicle_data)
    drop_table(:services) if table_exists?(:services)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy booking tables cannot be restored automatically."
  end
end

