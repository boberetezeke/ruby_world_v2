class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_save :write_to_git

  def self.git_baseable
    @git_baseable_options = {}
  end

  def self.git_baseable_options
    @git_baseable_options
  end

  def history_json
    git.history(object_class_name(self), self.id)
  end

  private

  def write_to_git
    if self.class.git_baseable_options
      git.update(object_class_name(self), self.id, object_attributes(self))
    end
  end

  def git
    Git.new(git_db_directory, "#{Rails.root}/bin")
  end

  def git_db_directory
    Rails.application.secrets[:git_db_directory]
  end

  def object_class_name(object)
    object.class.to_s.underscore
  end

  def object_attributes(object)
    object.attributes
  end
end
