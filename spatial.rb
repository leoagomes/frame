# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

# Spatial paritioning that is somewhat limited, but tries to be as efficient as
# possible.
#
# It preallocates two arrays:
# - `cell_starts` -- holds the index in `cell_entries` where the entries in this
#   cell live.
# - `cell_entries` -- holds the entries in each cell.
#
# Everything else is done with run-of-the-mill blocks and iterators.
#
# Entities are expected to be AABBs that respond to `x`, `y`, `w` (for width),
# and `h` (for height). I admit this naming is a bit awkward, but it's for
# compatibility with how DragonRuby handles things.
#
# Effectively, this means entities can be DR sprites, arrays, or anything else.
#
# To use this, you:
# 1. create a new Spatial::Hash
# 2. on each frame (that you'll do collision checking), you call `populate` with
#    an Enumeration of entities (meaning a collection that responds to `each`).
# 3. query the AABBs that are collision candidates for an entity with `query`,
#    and perform finer collision calculations on each of the yielded entities.
#    BEWARE: candidates may appear more than once. If that's an issue, call
#            `query_unique`.
#
# Example:
# spatial = Spatial::Hash.new(spacing: 32, max_entries: 100)
# ents = [[10, 10, 16, 16], # x = 10, y = 10, width = 16, height = 16
#         [20, 20, 8, 8]]   # x = 20, y = 20, width = 8, height = 8
# spatial.populate(ents)
#
# spatial.query(ents[0]) do |candidate|
#   # perform your finer-grained collision check here
# end
#
# Notes:
# - By default, the entities stored and yielded in the hash are the original
#   entity objects themselves. If you want to store something else, you can call
#   `populate_using` instead. This method takes a `to_proc`-able that will be
#   called on each entity to get the value to store in the hash.
#   For example:
#   spatial.populate_using(ents, :entity_id) # will store entity ids
#   # If you wanted to store something else entirely:
#   my_aabb_to_entity_mapping_proc = proc { |aabb| ... }
#   spatial.populate_using(ents, my_aabb_to_entity_mapping_proc)
#   Keep in mind that storing the entities themselves is more efficient, as it
#   requires one less call.
class Spatial
  class Hash
    attr_reader :spacing, :max_entries

    def initialize(spacing:, max_entries:)
      @spacing = spacing
      @max_entries = max_entries
      @cell_size = 2 * max_entries
      @cell_starts = Array.new(@cell_size + 1, 0)
      @cell_entries = Array.new(@max_entries, nil)
    end

    def populate(entities)
      clear_cells!
      determine_cell_sizes!(entities)
      determine_cell_starts!

      # populate entities
      entities.each do |entity|
        each_entity_aabb_cell(entity) do |cell_position|
          @cell_starts[cell_position] -= 1
          @cell_entries[@cell_starts[cell_position]] = entity
        end
      end
    end

    def populate_using(entities, to_id_procable = :itself)
      clear_cells!
      determine_cell_sizes!(entities)
      determine_cell_starts!

      # populate entities
      to_id =
        if to_id_procable.respond_to?(:call)
          to_id_procable
        else
          to_id_procable.to_proc
        end
      entities.each do |entity|
        each_entity_aabb_cell(entity) do |cell_position|
          @cell_starts[cell_position] -= 1
          @cell_entries[@cell_starts[cell_position]] = to_id.call(entity)
        end
      end
    end

    def query(entity)
      each_entity_aabb_cell(entity) do |cell_position|
        start = @cell_starts[cell_position]
        finish = @cell_starts[cell_position + 1]

        for index in start...finish
          candidate = @cell_entries[index]
          next unless candidate

          yield candidate
        end
      end
    end

    def query_unique(entity)
      considered = {}
      query(entity) do |candidate|
        next if considered[candidate]

        yield candidate
        considered[candidate] = true
      end
    end

    private

    def clear_cells!
      @cell_starts.fill(0)
      @cell_entries.fill(false)
    end

    def determine_cell_sizes!(entities)
      entities.each do |entity|
        each_entity_aabb_cell(entity) do |cell_position|
          @cell_starts[cell_position] += 1
        end
      end
    end

    def determine_cell_starts!
      start = 0
      i = 0
      while i < @cell_size
        start += @cell_starts[i]
        @cell_starts[i] = start
        i += 1
      end
      @cell_starts[@cell_size] = start
    end

    def each_entity_aabb_cell(entity)
      x1, y1 = entity.x, entity.y
      x2, y2 = entity.x + entity.w, entity.y + entity.h
      x1, y1 = cell_coordinate(x1), cell_coordinate(y1)
      x2, y2 = cell_coordinate(x2), cell_coordinate(y2)
      for xi in x1..x2
        for yi in y1..y2
          cell_position = hash_coordinates(xi, yi)
          yield cell_position
        end
      end
    end

    def hash_coordinates(x, y)
      h = (x * 9283711) ^ (y * 689287499)
      h.abs % @cell_size
    end

    def cell_coordinate(c)
      (c / @spacing).to_i
    end

    def min(a, b)
      # we could do [a, b].min, but that would create a new array, and we can
      # save that allocation with a simple `if`
      if a < b
        a
      else
        b
      end
    end
  end
end
