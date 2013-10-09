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
# with_relative_root accepts a list of arguments on which it does a File.join

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
 - delegated : file?, directory?, extname, size, readlines
               dirname, absolute?, relative?, cleanpath
               exist?, basename, stat, children, delete

 - delegated and post-processed :
  - basestring (basename to string)
  - dirstring (dirname to string)

With the help of Pathname but custom-made :
 - read : reads the file content and memoizes it
 - content : alias for the above-mentionned
 - content= : sets file content
 - save : saves to file if content is set and file path exists
 - save! : saves to file, loading content if need be, creates path if need be
 - mkdir : create a folder after the pathstring content if parent dir exists
 - mkdir! : create a folder after the pathstring, creates all path elements if need be
 - rename : self-explicit (does not save file though)
 - open : default mode is 'w' (if you need to read, the `read`)

Pathstring specifics (relative stuff available if a "relative_root" was set) :
 - relative! : switches to relative facade
 - absolute! : switches to absolute facade
 - absolute_dirname : absolute dirname as a Pathname
 - absolute_dirstring : absolute dirname as a String
 - relative_dirname : relative dirname as a Pathname
 - relative_dirstring : relative dirname as a String
 - relative_root : relative paths originate there
 - with_relative_root : (re)set the relative path origin

## PathstringRoot

`pathstring` also provides another small utility class : `PathstringRoot`. It
is a full-fledge `Pathstring`, look above for the specifics. On top of that, it
instantiates `Pathstring's` giving itself as relative path, exposing the new
`Pathstring` with its relative facade. It lists the a `Pathstring` children as
instances of `Pathstring`.

An example after the highly inedible above sentences :
```ruby
require 'pathstring_root'

root = PathstringRoot.join '/home/me', 'plop'

puts root.read('README.md')       # puts documentation

readme = root.enroot('README.md')
puts readme                       # puts README.md
puts readme.absolute              # puts '/home/me/plop/README.md'
puts readme.file?                 # puts true

readme = root.select('plap') # same as enroot but memoizes readme
                                  # for futher use

root.branching('plap') do |element|
  # custom ls
  puts "#{element} : #{element.size}" if element.file?
end

# but thanks to `select`, `root.branching do |element|` would have done the same

root.wire_branching # same a branching, filter on directories
root.leaf_branching # same a branching, filter on files

```

### Branching class

To determine how to cast the elements found, `PathstrinRoot` (or a subclass)
will look at its name and strip the 'Root' appendix from it.
`PlopRoot` or `Plip::PlapRoot` would instantiate `Plop` or `Plip::Plap` objects
respectively.

There is also an attribute writer `branching_class` to set it explicitly.

If the above-mentionned elements classes do not derive from `Pathtstring`, the
subclassing class would have to overload the `enroot` method (as it sticks too
much to `Pathstring` so far).

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
