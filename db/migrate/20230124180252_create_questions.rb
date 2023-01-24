class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question, :limit => 140
      t.text :context, :null => true, :blank => true
      t.text :answer, :limit => 1000, :null => true, :blank => true
      t.integer :ask_count, :default => 1
      t.string :audio_src_url, :default => "", :null => true, :blank => true, :limit => 255

      t.timestamps
    end
  end
end