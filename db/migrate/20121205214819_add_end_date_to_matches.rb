class AddEndDateToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :end_date, :date
  end
end
