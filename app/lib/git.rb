require "yaml"
require "json"

class Git
  class History
    def initialize(json)
      @json = json
    end
  end

  def initialize(base_directory, bin_directory)
    @base_directory = File.expand_path(base_directory)
    @bin_directory = File.expand_path(bin_directory)
  end

  def history(object_class_name, object_id)
    json = nil

    Dir.chdir(db_path) do
      output = `bash #{@bin_directory}/log-history.sh #{relative_filename(object_class_name, object_id)}`
      json = JSON.parse(output)
    end

    json
  end

  #def version_at(history)
  #  Dir.chdir(db_path) do
  #    attributes = YAML.load(StringIO.new(`git show #{filename2(object)}`))
  #  end
  #end

  def update(object_class_name, object_id, object_attributes)
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

    Dir.mkdir(path(object_class_name)) unless File.exist?(path(object_class_name))

    if File.directory?(path(object_class_name))
      File.open(full_filename(object_class_name, object_id), "w") {|f| f.write object_attributes.to_yaml }
      Dir.chdir(db_path) do
        system("git add #{full_filename(object_class_name, object_id)}")
        system("git commit -m \"update\"")
      end
    else
      puts "Warning: Unable to save file because file #{path(object_class_name)} is not a directory json file"
    end
  end

  def db_path
    @base_directory
  end

  def path(object_class_name)
    "#{db_path}/#{object_class_name}"
  end

  def full_filename(object_class_name, object_id)
    "#{path(object_class_name)}/#{object_id}.yml"
  end

  def relative_filename(object_class_name, object_id)
    "#{object_class_name}/#{object_id}.yml"
  end
end