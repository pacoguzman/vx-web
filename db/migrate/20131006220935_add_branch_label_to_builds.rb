class AddBranchLabelToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :branch_label, :string
  end
end
