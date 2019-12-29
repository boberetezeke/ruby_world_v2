require "spec_helper"
require "./app/lib/git"

describe Git do
  GIT_ROOT = "spec/git_root"
  GIT_BIN_DIR = "bin"

  before do
    Dir.mkdir(GIT_ROOT)
    Dir.chdir(GIT_ROOT) do
      system("git init")
    end
  end

  after do
    system("rm -rf #{GIT_ROOT}")
  end

  it "writes to git" do
    git = Git.new(GIT_ROOT, GIT_BIN_DIR)

    attributes = {color: "red", size: 1}
    git.update("widget", "abcd", attributes)

    expect(YAML.load(File.read("#{GIT_ROOT}/widget/abcd.yml"))).to eq(attributes)
  end

  it "returns history objects after two writes" do
    git = Git.new(GIT_ROOT, GIT_BIN_DIR)

    attributes = {color: "red", size: 1}
    git.update("widget", "abcd", attributes)

    attributes = {color: "blue", size: 2}
    git.update("widget", "abcd", attributes)

    history = git.history("widget", "abcd")
    expect(history.size).to eq(2)
  end
end