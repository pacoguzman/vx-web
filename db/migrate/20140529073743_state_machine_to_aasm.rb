class StateMachineToAasm < ActiveRecord::Migration
  def up
    rename_column :builds, :status, :state_machine_status
    add_column :builds, :status, :string

    Build.reset_column_information
    Build.where(:state_machine_status => 0).update_all(:status => "initialized")
    Build.where(:state_machine_status => 2).update_all(:status => "started")
    Build.where(:state_machine_status => 3).update_all(:status => "passed")
    Build.where(:state_machine_status => 4).update_all(:status => "failed")
    Build.where(:state_machine_status => 5).update_all(:status => "errored")

    remove_column :builds, :state_machine_status

    rename_column :jobs, :status, :state_machine_status
    add_column :jobs, :status, :string

    Job.reset_column_information
    Job.where(:state_machine_status => 0).update_all(:status => "initialized")
    Job.where(:state_machine_status => 2).update_all(:status => "started")
    Job.where(:state_machine_status => 3).update_all(:status => "passed")
    Job.where(:state_machine_status => 4).update_all(:status => "failed")
    Job.where(:state_machine_status => 5).update_all(:status => "errored")

    remove_column :jobs, :state_machine_status
  end

  def down
    rename_column :builds, :status, :aasm_status
    add_column :builds, :status, :integer, :default => 0, :null => false

    Build.reset_column_information
    Build.where(:aasm_status => "initialized").update_all(:status => 0)
    Build.where(:aasm_status => "started").update_all(:status => 2)
    Build.where(:aasm_status => "passed").update_all(:status => 3)
    Build.where(:aasm_status => "failed").update_all(:status => 4)
    Build.where(:aasm_status => "errored").update_all(:status => 5)

    remove_column :builds, :aasm_status

    rename_column :jobs, :status, :aasm_status
    add_column :jobs, :status, :integer, :default => 0, :null => false

    Job.reset_column_information
    Job.where(:aasm_status => "initialized").update_all(:status => 0)
    Job.where(:aasm_status => "started").update_all(:status => 2)
    Job.where(:aasm_status => "passed").update_all(:status => 3)
    Job.where(:aasm_status => "failed").update_all(:status => 4)
    Job.where(:aasm_status => "errored").update_all(:status => 5)

    remove_column :jobs, :aasm_status
  end
end
