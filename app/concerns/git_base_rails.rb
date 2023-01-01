require 'active_support/concern'
require 'git_base'

module GitBaseRails
  extend ActiveSupport::Concern
  included do
    after_initialize :init_git_options
    after_save :write_to_git
    serialize :__git_options
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
    Rails.application.credentials[:git_db_directory]
  end

  def self.git_db_directory(branch_name: 'master')
    File.join(git_db_base_directory, branch_name)
  end

  def get_uuid
    ActiveRecord::Base.connection.execute(
      'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; SELECT uuid_generate_v4();'
    ).first['uuid_generate_v4'];
  end

  def init_git_options
    self.__git_options ||= {}
  end

  def write_to_git
    if (options = self.class.git_baseable_options.merge(__git_options))
      attr = object_attributes(self)
      attr['id'] = get_uuid if attr['id'].nil?
      GitBaseRails
        .git_base(branch_name: options[:branch_name])
        .update(git_object_guid(id: attr['id']), attr)
    end
  end

  private

  def git_base
    GitBaseRails.git_base
  end

  def git_object_guid(id: nil)
    git_base.object_guid(self.class, object_class_name(self), id || self.id)
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

    def tag(tag_name, branch_name: 'master')
      GitBaseRails.git_base(branch_name: branch_name).tag(tag_name)
    end

    def history_since(since, branch_name: 'master')
      GitBaseRails.git_base(branch_name: branch_name).history(since: since)
    end
  end
end