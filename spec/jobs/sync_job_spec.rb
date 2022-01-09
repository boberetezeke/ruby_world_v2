require 'rails_helper'

describe SyncJob do
  def run(str)
    system(str)
  end
  it "runs" do
    run("rm -rf #{GitBaseRails.git_db_base_directory}")
    run("mkdir #{GitBaseRails.git_db_base_directory}")
    run("mkdir #{GitBaseRails.git_db_base_directory}/bare")
    Dir.chdir("#{GitBaseRails.git_db_base_directory}/bare") do
      run("git init --bare")
    end
    run("git clone #{GitBaseRails.git_db_base_directory}/bare #{GitBaseRails.git_db_base_directory}/master")
    Dir.chdir("#{GitBaseRails.git_db_base_directory}/master") do
      run("touch .keep")
      run("git add .keep")
      run("git commit -m 'initial setup'")
      run("git push")
    end

    SyncJob.perform_now
    expect(CsvStoreTodo.count).to eq(3)
    expect(Todo.count).to eq(3)
  end
end