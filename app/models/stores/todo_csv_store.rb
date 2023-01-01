class Stores::TodoCsvStore < Store
  def update_from_main_db_changes(changes)
    # changes.each do |change|
    #   if change.add?
    #     create store object from db object
    #   if change.delete?
    #     delete store object associated with db object
    #   else
    #     change store object based on db object changes
  end

  def update_from_remote
    return unless File.exist?(filename)

    store_ids = []
    CSV.foreach(filename) do |row|
      store_id, title, order, done = row
      done = done.present?

      store_ids.push(store_id)
      csv_store_todo = CsvStoreTodo.find_by(store_id: store_id)
      if csv_store_todo
        csv_store_todo.update(title: title, order: order, done: done)
      else
        csv_store_todo = CsvStoreTodo.create(
          store_id: store_id, title: title, order: order, done: done)
      end
      csv_store_todo.write_to_git
    end
    deleted_objects = CsvStoreTodo.where.not(store_id: store_ids)
    deleted_objects.destroy_all
  end

  def store_class
    CsvStoreTodo
  end

  def store_branch_name
    "csv"
  end
end