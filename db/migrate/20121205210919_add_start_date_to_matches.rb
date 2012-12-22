class AddStartDateToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :start_date, :date
  end
end
