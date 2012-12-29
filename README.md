# Pathstring

I was bored of all the `File.join` for not using `Pathname` everywhere, and
bored for all the `to_s` for using it. So i designed a midway.

Pathstring is a String, but it interfaces some of the Pathname instance
utilities, as well as a few other homebrewed ones.

Pathstring instances always know their absolute context (even when initialised
with relative paths) and their relative context (if a "relative root" is given),
and can switch easily from one to the other.

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install pathstring

With bundler, add it to your `Gemfile`:

``` ruby
gem "pathstring"
```

## Use

```ruby
require 'pathstring'

# path, relative root (optional)
# relative root can be set later on with relative root_with method
f = Pathstring.new '/home/me/my_project/LICENSE', Dir.home

# same as
f = Pathstring.join(Dir.pwd, 'LICENSE').with_relative_root(Dir.home)

puts f # => '/home/me/my_project/LICENSE'

f.absolute_dirstring # puts '/home/me/my_project'
f.relative_dirstring # puts 'my_project'
f.dirstring # puts '/home/me/my_project' because we are using the absolute facade

f.relative! # changes facade to relative
puts f # => 'my_project/LICENSE', relative from Dir.home
f.dirstring # puts 'my_project' because we are now using the relative facade

f.content = File.read('/home/me/my_other_project/LICENSE')
f.content << "And most important, do what the fuck you want with it !\n"
f.save
```

Pathstring behaves like a String but it knows from `Pathname` :
 - delegated : basename, extname, join, dirname, children, delete, exist?,
               readlines, size, split, stat, :file?, :absolute?, :relative?

 - delegated and post-processed :
  - basestring (basename to string)
  - dirstring (dirname to string)

With the help of Pathname but custom-made :
 - read : reads the file content and memoizes it
 - content : alias for the above-mentionned
 - content= : sets file content
 - save : saves to file if content is set and file path exists
 - save! : saves to file, loading content if need be, creates path if need be
 - rename : self-explicit (does not save file though)

Pathstring specifics (relative stuff available if a "relative_root" was set) :
 - relative! : switches to relative facade
 - absolute! : switches to absolute facade
 - absolute_dirname : absolute dirname as a Pathname
 - absolute_dirstring : absolute dirname as a String
 - relative_dirname : relative dirname as a Pathname
 - relative_dirstring : relative dirname as a String
 - relative_root : relative paths originate there
 - with_relative_root : (re)set the relative path origin

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
