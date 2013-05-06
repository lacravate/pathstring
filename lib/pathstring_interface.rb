# encoding: utf-8

require 'pedlar'

class PathstringInterface < String

  # delegations
  extend Pedlar

  # what we shamelessly steal from Pathname
  def_delegator  :@absolute, :to_s, :absolute
  def_delegator  :@absolute, :dirname, :absolute_dirname
  # here with a failsafe thanks to Pedlar
  safe_delegator :@relative, :to_s, :relative
  safe_delegator :@relative, :dirname, :relative_dirname

  # and even more
  def_delegators :facade_delegate, :dirname, :absolute?, :relative?, :cleanpath

  # and that again
  def_delegators :@absolute, :exist?, :basename, :stat, :children, :delete

  # two Pathname interfaces
  peddles Pathname, writer: [:absolute, :relative]

  # one utility class method, allows to instantiate a Pathstring with
  # a path elements list
  def self.join(*joins)
    new File.join(*joins)
  end

  #

  def initialize(path, relative_path=nil)
    # first arg to String more or less shrewdly
    stringified = path.instance_of?(Array) ? File.join(path) : path.to_s

    super stringified

    absolute_with relative_path || '', stringified

    # Pathstring specific methods definitions
    pathstring_specifics
  end

  #

  def join(*args)
    self.class.join self, *args
  end

  def split
    facade_delegate.split.map { |p| foster p }
  end

  #

  # definitions of relative! and absolute! that allow to switch facades
  %w|absolute relative|.each do |face|
    define_method "#{face}!".to_sym do
      instance_variable_get("@#{face}") && replace(send(face))
    end
  end

  def mkdir
    FileUtils.mkdir absolute rescue nil
  end

  def mkdir!
    FileUtils.mkdir_p absolute
  end

  private

  # fitting setter method for abolute resource
  def absolute_setter(root, path)
    Pathname.new(root).join(path).expand_path
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
        (pathname = send method) && foster(pathname)
      end
    end
  end

end

