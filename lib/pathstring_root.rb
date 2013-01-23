# encoding: utf-8

require 'pathstring'

class PathstringRoot < Pathstring

  # last selected element
  attr_reader :last

  attr_writer :element_class # ?

  # Useful memoize.
  # Needed to be done here because i
  # really don't want to do it enroot
  def select(path)
    @last = enroot path
  end

  # instantiate with parameter and set the right facade
  def enroot(path)
    element_class.new(path, self).tap { |e| e.relative! }
  end

  # list of an element's children as instances of the
  # elements class
  def branching(path=nil)
    join(path || @last || '').children.sort.map do |cell|
      enroot(cell).tap { |c| yield c if block_given? }
    end
  rescue # yeah yeah... i know Errno::ENOTDIR, but i don't care enough
    nil
  end

  private

  def element_class
    # inject is a funny way to do recursive stuff
    # (here to find a constant starting from Object)
    # Plip::Plap::PlopRoot will instantiate Plip::Plap::Plop objects
    @element_class ||= self.class.name.sub(/Root$/, '').split('::').inject(Object) do |constant, chunk|
      constant = constant.const_get chunk
    end
  end

end

