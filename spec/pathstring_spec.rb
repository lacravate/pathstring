# encoding: utf-8

require 'spec_helper'

describe Pathstring do

  subject { described_class.new File.join('spec', 'plop', 'plap') }

  describe 'join' do
    it "creates a Pathstring instance with class method join" do
      described_class.join('spec', 'plop', 'plap').should == subject
    end
  end

  describe 'read' do
    it "should be able to read the file content and fill its content attribute" do
      # no content => read doesn't crash and returns nil
      subject.read.should be_nil

      # force save with a content
      subject.save! 'ploup'

      # read has something to read now
      subject.read.should == 'ploup'
      # and content attribute was filled
      subject.content.should == 'ploup'
    end
  end

  describe 'rename' do
    it "should rename file to new name and set the instance internals right" do
      # rename to a file name of which some elements of the path don't exist
      subject.rename File.join('baz', 'plip', 'ploup')

      # instance changed its name
      subject.should == File.join('baz', 'plip', 'ploup')
      # as well as its internals as it responds correctly to dirname
      subject.dirstring.should == File.join('baz', 'plip')

      # let's try it with a absolute path, just for fun
      abs = described_class.new File.join('/plopinou', 'foo', 'plop', 'ploup')
      abs.rename File.join('/plopinou', 'foo', 'plup', 'ploup')

      # instance changed its name
      abs.should == File.join('/plopinou', 'foo', 'plup', 'ploup')
      # as well as its internals as it responds correctly to dirname
      abs.dirstring.should == File.join('/plopinou', 'foo', 'plup')
    end

    it "knows how to change its facade and rename" do
      p = described_class.new '/tmp/pim/poum', '/tmp/pim'

      p.should == '/tmp/pim/poum'

      p.relative!

      p.should == 'poum'
      p.absolute.should == '/tmp/pim/poum'

      p.rename 'pam'

      p.should == 'pam'
      p.absolute.should == '/tmp/pim/pam'
    end
  end

  it "can set relative facade after initialize" do
    p = described_class.join Dir.pwd, 'spec', 'plop', 'plap'

    p.relative!.should be_nil

    p.with_relative_root(Dir.pwd, 'spec')

    p.relative!.should == File.join('plop', 'plap')
  end

  describe 'save' do
    it "should be able to save the file contents" do
      # pathstring path doesn't exist. No can't do.
      subject.save.should be_nil

      # we create the dirname path
      FileUtils.mkdir_p subject.dirname
      # no content. that's a touch.
      subject.save.should be_true

      # save is succesfull with path and content
      subject.content = 'plaup'
      subject.save.should be_true
      subject.save('plawp').should be_true
      File.read(subject).should == 'plawp'
    end
  end

  describe 'save!' do
    it "should be able to save the file contents" do
      subject.exist?.should be_false
      # touch
      subject.save!.should be_true
      subject.save!('bim!').should be_true
      File.read(subject).should == 'bim!'
    end
  end

  describe 'dirname' do
    let(:absolute_relative_specs) {
      subject.absolute.should == File.join(Dir.pwd, 'spec', 'plop', 'plap')
      subject.relative.should == File.join('spec', 'plop', 'plap')
      subject.absolute_dirname.to_s.should == File.join(Dir.pwd, 'spec', 'plop')
      subject.absolute_dirstring.should == File.join(Dir.pwd, 'spec', 'plop')
      subject.relative_dirname.to_s.should == File.join('spec', 'plop')
      subject.relative_dirstring.should == File.join('spec', 'plop')
    }

    context "absolute path" do
      subject { described_class.new File.join(Dir.pwd, 'spec', 'plop', 'plap') }

      it "should be able to render dirnames and paths" do
        subject.absolute.should == File.join(Dir.pwd, 'spec', 'plop', 'plap')
        subject.relative.should be_nil
        subject.absolute_dirname.to_s.should == File.join(Dir.pwd, 'spec', 'plop')
        subject.absolute_dirstring.should == File.join(Dir.pwd, 'spec', 'plop')
        subject.relative_dirname.should be_nil
        subject.relative_dirstring.should be_nil
        subject.should == File.join(Dir.pwd, 'spec', 'plop', 'plap')
        subject.dirname.to_s.should == File.join(Dir.pwd, 'spec', 'plop')
      end
    end

    context "absolute path, specifying relative path root" do
      subject { described_class.new File.join(Dir.pwd, 'spec', 'plop', 'plap'), Dir.pwd }

      it "should be able to render dirnames and paths" do
        absolute_relative_specs
        subject.should == File.join(Dir.pwd, 'spec', 'plop', 'plap')
        subject.dirname.to_s.should == File.join(Dir.pwd, 'spec', 'plop')
      end
    end

    context "relative path" do
      it "should be able to render dirnames and paths" do
        absolute_relative_specs
        subject.should == File.join('spec', 'plop', 'plap')
        subject.dirname.to_s.should == File.join('spec', 'plop')
      end
    end
  end

  after {
    FileUtils.rm_rf File.join(Dir.pwd, 'spec', 'plip')
    FileUtils.rm_rf File.join(Dir.pwd, 'spec', 'plop')
  }

end
