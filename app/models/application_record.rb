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
    git = Git.new(Rails.application.secrets[:git_db_directory])
    git.history(self)
  end

  private

  def write_to_git
    if self.class.git_baseable_options
      git = Git.new(Rails.application.secrets[:git_db_directory])
      git.update(self)
    end
  end
end
