class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.string :username
      t.string :uid
      t.string :provider
      t.string :token

      t.timestamps
    end
  end
end
