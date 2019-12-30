require 'active_support/concern'

module GitBaseRails
  extend ActiveSupport::Concern
  included do
    after_save :write_to_git
  end

  def history_json
    git_base.history(object_class_name(self), self.id)
  end

  private

  def write_to_git
    if self.class.git_baseable_options
      git_base.update(object_class_name(self), self.id, object_attributes(self))
    end
  end

  def git_base
    GitBase.new(git_db_directory, "#{Rails.root}/bin")
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
  class_methods do
    def git_baseable
      @git_baseable_options = {}
    end

    def git_baseable_options
      @git_baseable_options
    end

  end
end