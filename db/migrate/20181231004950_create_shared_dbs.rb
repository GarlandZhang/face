class CreateSharedDbs < ActiveRecord::Migration[5.1]
  def change
    create_table :shared_dbs do |t|

      t.timestamps
    end
  end
end
