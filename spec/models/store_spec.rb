require 'rails_helper'

describe Store do
  before do
    clean_git_repos
  end

  describe "#accumulate_local_changes" do
    let(:csv_store_todo) { CsvStoreTodo.new(title: 'do this', order: 1, done: false, __git_options: { branch_name: 'master' }) }
    let(:csv_store_todo_delete) { CsvStoreTodo.new(title: 'do that', order: 1, done: false, __git_options: { branch_name: 'master' }) }
    let(:csv_store_todo_new) { CsvStoreTodo.new(title: 'do the other', order: 1, done: false, __git_options: { branch_name: 'master' }) }
    let(:todo_csv_store)  { Stores::TodoCsvStore.new(filename: 'spec/fixtures/todo.csv') }

    before do
      csv_store_todo.save
      csv_store_todo_delete.save
      CsvStoreTodo.tag('before-accumulate')
    end

    it "returns a history entry for a change" do
      csv_store_todo.update(done: true)
      history = CsvStoreTodo.history_since('before-accumulate')
      expect(history.entries.size).to eq(1)
    end

    it "accumulates changes" do
      csv_store_todo.update(done: true)
      csv_store_todo_delete_id = csv_store_todo_delete.id
      csv_store_todo_delete.destroy
      csv_store_todo_new.save

      changes = todo_csv_store.accumulate_local_changes
      expect(changes.size).to eq(3)
      expect(changes.is_a?(Hash)).to be_truthy
      expect(changes.keys).to match_array([csv_store_todo.id, csv_store_todo_delete_id, csv_store_todo_new.reload.id])

      expect(changes[csv_store_todo.id]).to eq("a change")
      expect(changes[csv_store_todo_delete_id]).to eq("a deleted change")
      expect(changes[csv_store_todo_new_id]).to eq("a creation change")
    end
  end

  describe "#accumulate_remote_changes" do
  end
end
