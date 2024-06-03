class AddResetSentAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :reset_sent_at, :datetime
  end
end
