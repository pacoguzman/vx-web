class AddCompanyIdToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :company_id, :integer

    execute %{
      UPDATE projects SET company_id = (SELECT companies.id FROM companies LIMIT 1)
    }.compact

    change_column :projects, :company_id, :integer, null: false

    add_index :projects, [:company_id]
    remove_index :projects, :name
    add_index :projects, [:company_id, :name], unique: true
  end

  def down
    remove_column :projects, :company_id
    add_index :projects, :name, unique: true
  end
end
