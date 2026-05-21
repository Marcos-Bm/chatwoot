# rubocop:disable all
class CreateLeadPipelines < ActiveRecord::Migration[7.0]
  def change
    create_table :lead_pipelines do |t|
      t.references :account, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true
      t.string :current_stage, null: false
      t.integer :score, default: 0
      t.bigint :assigned_user_id

      t.timestamps
    end

    add_index :lead_pipelines, :assigned_user_id
    add_index :lead_pipelines, [:account_id, :current_stage]
  end
end
