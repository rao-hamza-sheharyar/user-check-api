class CreateIntegrityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :integrity_logs do |t|
      t.string :idfa
      t.string :ban_status
      t.string :ip
      t.boolean :rooted_device
      t.string :country
      t.boolean :proxy
      t.boolean :vpn

      t.timestamps
    end

    add_index :integrity_logs, :idfa
  end
end
