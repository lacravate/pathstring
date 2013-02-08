# encoding: utf-8

require 'pedlar'

# we want a string, a little bit more intelligent though, so...
class Pathstring < String

  # delegations
  extend Pedlar

  # what we shamelessly steal from Pathname
  def_delegator  :@absolute, :to_s, :absolute
  def_delegator  :@absolute, :dirname, :absolute_dirname
  # here with a failsafe thanks to Pedlar
  safe_delegator :@relative, :to_s, :relative
  safe_delegator :@relative, :dirname, :relative_dirname

  # and even more
  def_delegators  :facade_delegate, :dirname, :absolute?, :relative?

  # and that again
  def_delegators :@absolute, :exist?, :file?, :basename, :extname, :join, :split,
                             :size, :stat, :children, :delete, :readlines

  # three interfaces
  peddles Pathname
  pathname_accessor :relative_root
  pathname_writer :absolute
  pathname_writer :relative

  # only writer, getter is implicitly defined within the read method
  attr_writer :content

  # one utility class method, allows to instantiate a Pathstring with
  # a path elements list
  def self.join(*joins)
    new File.join(*joins)
  end

  def initialize(path, relative_path=nil)
    stringified = path.to_s
    # first arg to String
    super stringified

    # set relative origin, with '' as default
    # to allow setting absolute path in any case
    relative_root_with relative_path || ''
    absolute_with stringified

    # if path argument is not absolute, then it's relative...
    relative_with stringified if absolute != stringified
    # if path argument is not set yet and we're given a relative_path argument
    relative_with @absolute.relative_path_from(@relative_root) if !@relative && relative_path

    # Pathstring specific methods definitions
    pathstring_specifics
  end

  # (re)set the relative origin
  # set the relative facade in the process
  def with_relative_root(*root)
    # Tap because i like tap
    # No, tap because i want this to be chainable with `new` for example
    tap do |p|
      relative_root_with File.join(root)
      relative_with @absolute.relative_path_from(@relative_root)
    end
  end

  # definitions of relative! and absolute! that allow to swith facades
  %w|absolute relative|.each do |face|
    define_method "#{face}!".to_sym do
      instance_variable_get("@#{face}") && replace(send(face))
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
    absolute_with @relative
    replace new_name
  end

  # save file content, if the dirname path exists
  def save(content=nil)
    @content = content if content
    open { |f| f.write @content || '' } if absolute_dirname.exist?
  end

  # save file content
  # forces the dirname creation if it doesn't exist
  def save!(content=nil)
    FileUtils.mkdir_p absolute_dirname
    save content || read
  end

  def open(mode=nil)
    @absolute.open(mode || 'w') { |f| yield f if block_given? }
  end

  # man ruby
  alias :content :read

  private

  # fitting setter method for abolute resource
  def absolute_setter(path)
    relative_root.join(path).expand_path
  end

  # is the current facade absolute or relative ?
  def facade_delegate
    absolute == self ? @absolute : @relative
  end

  # Pathstring specific methode definitions
  def pathstring_specifics
    # anything that's called *basename* or *dirname* will have
    # its basestring or dirstring couterpart
    methods.grep(/basename|dirname/).each do |method|
      define_singleton_method method.to_s.sub('name', 'string').to_sym do
        (pathname = send method) && pathname.to_s
      end
    end
  end

end
