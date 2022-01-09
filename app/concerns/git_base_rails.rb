require 'active_support/concern'
require 'git_base'

module GitBaseRails
  extend ActiveSupport::Concern
  included do
    after_save :write_to_git
  end

  def history(branch_name: 'master')
    GitBaseRails.git_base(branch_name: branch_name).history(object_guid: git_object_guid)
  end

  def self.git_base(branch_name: 'master', initialize_if_doesnt_exist: true, set_class_var: true)
    Dir.mkdir(git_db_base_directory) unless File.exist?(git_db_base_directory)
    directory = git_db_directory(branch_name: branch_name)
    base = GitBase::Database.new(directory, "#{Rails.root}/bin", initialize_if_doesnt_exist: initialize_if_doesnt_exist)
    @git_base ||=  base if set_class_var
    base
  end

  def self.git_db_base_directory
    Rails.application.secrets[:git_db_directory]
  end

  def self.git_db_directory(branch_name: 'master')
    File.join(git_db_base_directory, branch_name)
  end

  private

  def write_to_git
    if (options = self.class.git_baseable_options)
      GitBaseRails.git_base(branch_name: options[:branch_name]).update(git_object_guid, object_attributes(self))
    end
  end

  def git_base
    GitBaseRails.git_base
  end

  def git_object_guid
    git_base.object_guid(self.class, object_class_name(self), self.id)
  end

  def object_class_name(object)
    object.class.to_s.underscore
  end

  def object_attributes(object)
    object.attributes
  end

  class_methods do
    def git_baseable(branch_name: "master")
      @git_baseable_options = {branch_name: branch_name}
    end

    def git_baseable_options
      @git_baseable_options
    end

    def from_attributes(attributes)
      new(attributes)
    end

    def create_git_for_all
      self.all.find_each do |object|
        object.send(:write_to_git)
      end
    end
  end
end