# encoding: utf-8

require 'spec_helper'

describe PathstringRoot do

  describe 'enroot && select && last' do
    subject { described_class.new File.join(Dir.pwd, 'spec', 'plop', 'plap') }

    it "knows how to instantiate a Pathstring with the right path and set its facade to relative" do
      selected = subject.select(File.join(Dir.pwd, 'spec', 'plop', 'plap', 'ploum'))
      selected.should == Pathstring.new('ploum')
      selected.should == 'ploum'
      selected.absolute.should == Pathstring.join(Dir.pwd, 'spec', 'plop', 'plap', 'ploum')

      subject.last == selected

      rooted = subject.enroot(File.join('plam', 'ploc'))
      rooted.should == Pathstring.join('plam', 'ploc')
      rooted.should == 'plam/ploc'
      rooted.absolute.should == Pathstring.join(Dir.pwd, 'spec', 'plop', 'plap', 'plam', 'ploc')

      subject.last == selected
    end
  end

  describe 'branching' do
    subject { described_class.new Dir.pwd }

    it "gives a list of a directory elements as istances of Pathstring" do
      subject.branching('spec').should =~ Dir[File.join('spec', '*')]
      subject.branching('spec') do |e|
        e.is_a?(Pathstring).should be_true
      end

      subject.branching('spec/spec_helper.rb').should be_nil
    end
  end

end
