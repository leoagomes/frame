## frame

> **F**lexible **R**uby **A**nimation & **M**ath **E**xtensions

Frame is a collection of [public domain](./LICENSE) utilities to help accelerate
Ruby game development.

Frame utilities are compatible with as many Ruby runtimes as possible, with a
primary focus on [DragonRuby GTK](https://dragonruby.org).

### Toolbox

Currently, the following are available in `frame`'s toolbox:
- [`vector.rb`](./frame/vector.rb)
  A collection of 2D math utilities + a `Vector` class with it.

With more to come...
- `spatial.rb`
  Hopefully the best kickstart to your spatial hashing needs.

> **Author's note:**
>
> All tools are added by default to the global namespace. Feel free to modify
> the files if that's not what you want.
>
> We try not to reference classes by name, this is to help you with refactoring,
> in case that name is not to your liking.

### Licensing & Philosophy

As mentioned above, all code in this repository is released to the public
domain under the [Unlicense](./LICENSE). Do with it as you please.

Each tool should be as self-contained as possible, including documentation and
examples. Copying the file you want should be all you need. This is to make
using these in your project as simple as possible.

Attribution **not required**, but definitely appreciated.

Please consider sharing any improvements you make to this code. I (and likely
the Ruby gamedev community) will definitely appreciate it. It's not your game's
secret sauce.

### Contributing

All contributions are very much welcome. Please keep in mind any code you
contribute will be shared under the [Unlicense](./LICENSE) as well.

