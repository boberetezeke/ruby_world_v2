module Store
  class BaseStore
    def process_changes(changes)
      process_mods(changes[:mod])
      process_adds(changes[:add])
      process_removals(changes[:rem])
    end

    def store_class
      raise "store_class must be set by the sub-class"
    end

    def store_branch_name
      raise "store_branch_name must be set by the sub-class"
    end

    def process_mods(mods)
      mods.each do |mod|
        attributes = YAML.load(File.open(mod))
        todo = store_class.find(attributes['id'])
        todo.update_attributes(attributes)
      end
    end

    def process_adds(adds)
      adds.each do |add|
        attributes = YAML.load(File.open(add))
        store_class.create(attributes)
      end
    end

    def process_removals(removals)
      removals.each do |removal|
        attributes = YAML.load(File.open(removal))
        store_class.destroy(attributes['id'])
      end
    end
  end
end