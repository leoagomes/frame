## frame

> **F**lexible **R**uby **A**nimation & **M**ath **E**xtensions

Frame is a collection of [public domain](./LICENSE) utilities to help accelerate
Ruby game development. Its utilities are compatible with as many Ruby runtimes
as possible, with a primary focus on [DragonRuby GTK](https://dragonruby.org).

### Toolbox

Currently, the following are available in `frame`'s toolbox:
- [`vector.rb`](./vector.rb) - A `Vector` class with 2D vector math.
- `spatial.rb` - _coming soon_

> **Author's note:**
>
> All tools are added by default to the global namespace. Feel free to modify
> the files if that's not what you want.
>
> We try not to reference classes by name, this is to help you with refactoring,
> in case that name is not to your liking.

### Usage

There are two supported ways to use this in your project:
1. Copy one of the files you need into your project and `require` it.
   This lets you include only what you need.
2. Clone this repository in a subdirectory in your project and `require` from it.
   This adds all tools to your project.
   When using DragonRuby, we recommend cloning it into `lib/frame` and
   `require 'lib/frame/<tool>.rb'`.

### License & Philosophy

As mentioned above, all code in this repository is released to the public
domain under the [Unlicense](./LICENSE). Do with it as you please, no
attribution required (though appreciated!).

Each tool should be as self-contained as possible, including documentation and
examples. Copying the file you want should be all you need. This is to make
using these in your project as simple as possible.

Please consider sharing any improvements you make to this code. I (and likely
the Ruby gamedev community) will definitely appreciate it. It's not your game's
secret sauce.

### Contributing

All contributions are very much welcome. Please keep in mind any code you
contribute will be shared under the [Unlicense](./LICENSE) as well.
