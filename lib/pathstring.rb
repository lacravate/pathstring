# encoding: utf-8

require 'pathstring_interface'
require 'pathstring_root'

# we want a string, a little bit more intelligent though, so...
class Pathstring < PathstringInterface

  # a little more borrowing from Forwardable
  def_delegators :@absolute, :file?, :directory?, :extname, :size, :readlines

  # relying on our own now
  peddles PathstringRoot, accessor: [:relative_root]

  # only writer, getter is implicitly defined within the read method
  attr_accessor :content

  def initialize(path, relative_path=nil)
    super
    stringified = path.to_s
    relative_root_with relative_path || ''

    # if path argument is not absolute, then it's relative...
    relative_with stringified if absolute != stringified
    # if path argument is not set yet and we're given a relative_path argument
    relative_with @absolute.relative_path_from(@relative_root) if !@relative && relative_path
  end

  # (re)set the relative origin
  # set the relative facade in the process
  def with_relative_root(*root)
    # Tap because i like tap
    # No, tap because i want this to be chainable with `new` for example
    tap do |p|
      relative_root_with File.join(root)
      relative_with @absolute.relative_path_from(@relative_root)
      absolute? || replace(self, relative)
    end
  end

  # read through a mere delegation to pathname
  # fill up content attribute in the process
  def read
    @content = @absolute.read if exist?
  end

  # rename not only string value, but resets the internal pathname
  # to return apt values to basename or dirname for instance
  def rename(new_name)
    relative_with new_name.sub(@relative_root.to_s, '')
    absolute_with @relative_root, @relative
    replace new_name
  end

  def save(*data)
    persist *data
  end

  def save!(*data)
    FileUtils.mkdir_p absolute_dirname
    persist *data
  end

  def open(mode=nil)
    @absolute.open(mode || 'w') { |f| yield f if block_given? }
  end

  private

  def persist(*data)
    @content = data.first if data.any?
    open { |f| f.write(@content || read) } if absolute_dirname.exist?
  end

  def foster(path)
    self.class.new path, relative_root.send(path_facade(path))
  end

  def path_facade(path)
    (Pathname.new(path).absolute? && 'absolute') || 'relative'
  end

end
