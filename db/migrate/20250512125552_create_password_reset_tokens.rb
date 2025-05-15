class CreatePasswordResetTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :password_reset_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.datetime :revoked_at
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end

    add_index :password_reset_tokens, :token_digest, unique: true
  end
end
