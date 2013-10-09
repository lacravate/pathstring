# encoding: utf-8

require 'pathstring_interface'

class PathstringRoot < PathstringInterface

  # last selected element
  attr_reader :last

  attr_writer :branching_class

  # Useful memoize.
  # Needed to be done here because i
  # really don't want to do it enroot
  def select(path)
    @last = enroot path if path
  end

  # instantiate with parameter and set the right facade
  def enroot(path)
    branching_class.new(path, self).tap { |e| e.relative! }
  end

  # list of an element's children as instances of the
  # elements class
  def branching(path=nil, type=nil)
    branchings(path, type).map do |cell|
      enroot(cell).tap { |c| yield c if block_given? }
    end
  rescue # yeah yeah... i know Errno::ENOTDIR, but i don't care enough
    nil
  end

  # directory contents
  # that's... not pretty
  def branchings(path, type)
    # filter on wire or leaf, sorted list
    if type
      join(path || @last || '').children.select { |child| child.send "#{type}?" }.sort
    # no filter, yet all wires sorted out first, then all leaves sorted out as well
    else
      join(path || @last || '').children.inject([[],[]]) { |h, c|
        h.tap do |plop|
          (h.send(c.file? ? 'last' : 'first') << c).sort!
        end
      }.flatten
    end
  end

  # i love meta !
  # wire_branching and leaf_branching definitions
  { leaf: 'file', wire: 'directory' }.each do |prefix, type|
    define_method "#{prefix}_branching".to_sym do |*args, &block|
      branching(args.first, type) do |cell|
        block.call(cell) unless block.nil?
      end
    end
  end

  # a little utility method to make PathstringRoot complete
  def read(path=nil)
    (select(path) || @last).read rescue nil
  end

  private

  def branching_class
    # inject is a funny way to do recursive stuff
    # (here to find a constant starting from Object)
    # Plip::Plap::PlopRoot will instantiate Plip::Plap::Plop objects
    @branching_class ||= self.class.name.sub(/Root$/, '').split('::').inject(Object) do |constant, chunk|
      constant = constant.const_get chunk
    end
  end

end
