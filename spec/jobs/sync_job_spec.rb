require 'rails_helper'

describe SyncJob do
  def run(str)
    system(str)
  end

  before do
    clean_git_repos
  end

  it "pulls three records from the csv store" do
    csv_store = Stores::TodoCsvStore.create(filename: "spec/fixtures/todo.csv")
    SyncJob.perform_now(csv_store.id)
    expect(CsvStoreTodo.count).to eq(3)
  end

  it "pushes three records to the csv store" do
    csv_store = Stores::TodoCsvStore.create(filename: "spec/fixtures/todo-empty.csv")
    SyncJob.perform_now(csv_store.id)
    expect(CsvStoreTodo.count).to eq(0)

    CsvStoreTodo.create(title: 'do something', order: 0, done: false, master_branch: true)
    CsvStoreTodo.create(title: 'do something else', order: 1, done: true, master_branch: true)
    CsvStoreTodo.create(title: 'do nothing else', order: 2, done: false, master_branch: true)

    Stores::TodoCsvStore.update(filename: "spec/fixtures/todo-out.csv")

    SyncJob.perform_now(csv_store.id)

    # read in the created CSV
    rows = []
    if File.exist?("spec/fixtures/todo-out.csv")
      CSV.open("spec/fixtures/todo-out.csv") do |row|
        rows.push({ title: row[0], order: row[1], done: row[2] })
      end
    end

    expect(rows).to match_array([
      { title: 'do something', order: 0, done: false },
      { title: 'do something else', order: 1, done: true },
      { title: 'do nothing else', order: 2, done: false }
    ])
  end
end