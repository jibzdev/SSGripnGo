class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, index: { unique: true }, foreign_key: true
      t.integer :rating, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, default: true, null: false

      t.timestamps
    end

    add_index :reviews, :published
  end
end

