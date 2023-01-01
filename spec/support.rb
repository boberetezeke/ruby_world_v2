def run(str)
  system(str)
end

def clean_git_repos
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