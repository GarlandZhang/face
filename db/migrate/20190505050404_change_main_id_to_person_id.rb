class ChangeMainIdToPersonId < ActiveRecord::Migration[5.2]
  def change
    rename_column :relationships, :main_id, :person_id
  end
end
