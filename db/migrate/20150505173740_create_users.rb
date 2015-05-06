class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.integer :total_commits_last_year

      t.timestamps
    end
  end
end
