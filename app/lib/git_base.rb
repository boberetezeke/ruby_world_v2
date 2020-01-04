require "yaml"
require "json"

class GitBase
  class ObjectId
    attr_reader :klass, :class_name, :id
    def initialize(klass, class_name, id)
      @klass = klass
      @class_name = class_name
      @id = id
    end
  end

  class HistoryEntry
    attr_reader :sha, :author, :message, :file_entry, :time

    def initialize(git_base, file_entry, json)
      @git_base = git_base
      @file_entry = file_entry
      @sha = json['commit']
      @author = json['author']
      @message = json['message']
      @time = json['date']
    end

    def retrieve
      @git_base.version_at(self)
    end
  end

  class History
    attr_reader :entries

    def initialize(git_base, file_entry, json)
      @git_base = git_base
      @file_entry = file_entry
      @json = json
      @entries = json.map{|j| HistoryEntry.new(git_base, file_entry, j)}
    end
  end

  class FileEntry
    attr_reader :object_class_name, :object_id
    def initialize(object_id)
      @object_id = object_id
    end

    def relative_filename
      "#{@object_id.class_name}/#{@object_id.id}.yml"
    end

    def full_filename(db_path)
      "#{path_for_class(db_path)}/#{@object_id.id}.yml"
    end

    def path_for_class(db_path)
      "#{db_path}/#{@object_id.class_name}"
    end

    def as_object(attributes)
      @object_id.klass.new(attributes)
    end
  end

  def initialize(base_directory, bin_directory)
    @base_directory = File.expand_path(base_directory)
    @bin_directory = File.expand_path(bin_directory)
  end

  def object_id(*args)
    ObjectId.new(*args)
  end

  def history(object_id)
    json = nil

    file_entry = FileEntry.new(object_id)
    Dir.chdir(db_path) do
      output = `bash #{@bin_directory}/log-history.sh #{file_entry.relative_filename}`
      json = JSON.parse(output)
    end

    History.new(self, file_entry, json)
  end

  def version_at(history_entry)
    attributes = nil
    Dir.chdir(db_path) do
      attributes = YAML.load(StringIO.new(`git show #{history_entry.sha}:#{history_entry.file_entry.relative_filename}`))
    end
    history_entry.file_entry.as_object(attributes)
  end

  def update(object_id, object_attributes)
    fe = FileEntry.new(object_id)
    unless File.exist?(db_path)
      Dir.mkdir(db_path)
      Dir.chdir(db_path) do
        system("git init")
      end
    end

    unless File.directory?(db_path)
      puts "Warning: Unable to save file because file #{db_path} is not a directory as db path"
      return
    end

    Dir.mkdir(fe.path_for_class(db_path)) unless File.exist?(fe.path_for_class(db_path))

    if File.directory?(fe.path_for_class(db_path))
      File.open(fe.full_filename(db_path), "w") {|f| f.write object_attributes.to_yaml }
      Dir.chdir(db_path) do
        system("git add #{fe.relative_filename}")
        system("git commit -m \"update\"")
      end
    else
      puts "Warning: Unable to save file because file #{fe.path_for_class(db_path)} is not a directory json file"
    end
  end

  def db_path
    @base_directory
  end
end