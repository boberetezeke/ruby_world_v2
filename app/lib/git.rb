class Git
  class History
    def initialize(json)
      @json = json
    end
  end

  def initialize(base_directory)
    @base_directory = base_directory
  end

  def history(object)
    json = nil
    Dir.chdir(db_path) do
      json = JSON.parse(`bash #{Rails.root}/bin/log-history.sh #{filename2(object)}`)
    end

    json
  end

  def update(object)
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

    Dir.mkdir(path) unless File.exist?(path(object))

    if File.directory?(path(object))
      File.open(filename(object), "w") {|f| f.write object.attributes.to_yaml }
      Dir.chdir(db_path) do
        system("git add #{filename(object)}")
        system("git commit -m \"update\"")
      end
    else
      puts "Warning: Unable to save file because file #{path(object)} is not a directory json file"
    end
  end

  def db_path
    @base_directory
  end

  def path(object)
    class_name = object.class.to_s.underscore
    "#{db_path}/#{class_name}"
  end

  def filename(object)
    "#{path(object)}/#{object.id}.yml"
  end

  def filename2(object)
    class_name = object.class.to_s.underscore
    "#{class_name}/#{object.id}.yml"
  end
end