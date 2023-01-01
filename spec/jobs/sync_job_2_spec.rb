require 'rails_helper'

describe SyncJob2 do
  def run(str)
    system(str)
  end

  before do
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
  end

  it "pulls three records from the csv store" do
    csv_store = Stores::TodoCsvStore.create(filename: "spec/fixtures/todo.csv")
    SyncJob2.perform_now([csv_store.id])
    expect(CsvStoreTodo.count).to eq(3)
  end
end

