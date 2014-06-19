class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :company, index: true, null: false
      t.decimal :amount,       null: false
      t.string :state,         null: false
      t.string :description
      t.datetime :started_at,  null: false
      t.datetime :finished_at, null: false
      t.timestamps
    end
  end
end
