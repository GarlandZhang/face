class FixColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :relationships, :main_id_id, :person_id
    rename_column :relationships, :friend_id_id, :friend_id
  end
end
