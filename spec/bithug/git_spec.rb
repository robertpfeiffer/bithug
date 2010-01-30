require File.expand_path('../../spec_helper', __FILE__)

describe Bithug::Wrapper::Git do
  before(:each) do
    @repo = Bithug::Wrapper::Git.new("testrepo")
  end

  it "should initialize git repos" do
    @repo.init
    File.directory?(ENV["HOME"]/"testrepo").should be_true
  end

  it "should clone the testrepo" do
    repo = Bithug::Wrapper::Git.new("pullrepo", @repo.path)
    repo.init
    File.directory?(ENV["HOME"]/"pullrepo").should be_true
  end

  it "should read logs from the testrepo" do
    repo = Bithug::Wrapper::Git.new("commitrepo", "testrepo")
    repo.exec("clone", repo.remote, repo.path)
    File.open(repo.path/"test.txt", 'w') do |f|
      f.write("Some testfile")
    end
    repo.exec("add", "test.txt")
    repo.exec("commit", "-m", '"test commit"')
    repo.exec("push", "origin", 'master')
    @repo.log.size.should == 1
    @repo.log.first[:message].should == "test commit"
  end

  it "should be able to list repository contents" do
    repo = Bithug::Wrapper::Git.new("lsrepo", "testrepo")
    repo.exec("clone", repo.remote, repo.path)
    FileUtils.mkdir_p(repo.path/"subdir"/"subdir2")
    File.open(repo.path/"test2.txt", 'w') { |f| f.write("Some testfilesssss") }
    File.open(repo.path/"subdir"/"test.txt", 'w') { |f| f.write("Some other testfile") }
    File.open(repo.path/"subdir"/"subdir2"/"test.txt", 'w') { |f| f.write("Some deep testfile") }
    repo.exec("add", ".")
    repo.exec("commit", "-m", '"test commit"')
    repo.exec("push", "origin", "master")
    @repo.ls["test2.txt"].should_not be_nil
    @repo.ls["subdir"]["test.txt"].should_not be_nil
    @repo.ls["subdir"]["subdir2"]["test.txt"].should_not be_nil
  end
end
