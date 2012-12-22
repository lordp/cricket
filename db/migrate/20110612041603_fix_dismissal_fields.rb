class FixDismissalFields < ActiveRecord::Migration
  def self.up
    add_column :innings, :dismissal_fielder_id, :integer
    add_column :innings, :dismissal_other_fielder_id, :integer

    remove_column :innings, :dismissed_by

    rename_column :innings, :dismissal_type, :dismissal_text
  end

  def self.down
    add_column :innings, :dismissed_by, :string

    remove_column :innings, :dismissal_fielder_id
    remove_column :innings, :dismissal_other_fielder_id

    rename_column :innings, :dismissal_text, :dismissal_type
  end
end
