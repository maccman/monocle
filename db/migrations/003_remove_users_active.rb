Sequel.migration do
  change do
    alter_table :users do
      drop_column :active
      drop_column :activated_at
    end
  end
end