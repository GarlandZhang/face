class AddFaceIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :person_id, :string
  end
end
