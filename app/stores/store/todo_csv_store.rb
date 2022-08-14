module Store
  class TodoCsvStore < BaseStore
    def write_to_git
      CSV.foreach("todo.csv") do |row|
        csv_store_todo = CsvStoreTodo.new(
          store_id: row[0], title: row[1], order: row[2], done: row[3].present?)
        csv_store_todo.write_to_git
      end
    end

    def store_class
      CsvStoreTodo
    end

    def store_branch_name
      "csv"
    end
  end
end