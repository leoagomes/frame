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

# A 2D vector implementation. (Intended for use with DragonRuby GTK)
#
# Because DRGTK arrays, hashes, and entities respond to `x`, `y`, these utils
# use duck typing for its operations. You don't have to pass in vectors, you
# can pass anything that responds to `x`, `y`.
#
# Methods that end with a ! perform the operation inline, modifying the Vector
# itself or, for Vector class methods, the first argument. Returning the
# modified vector. These inline functions expect the operation target to also
# respond to `x=` and `y=`.
#
# When a function needs to return a (new) Vector-like object, it instantiates
# a Vector.
#
# There are two ways you can use this library:
# 1. You can instantiate Vectors and use them directly, or
# 2. operate on vector-like objects using the Vector class methods.
#
# For example:
# # Using Vector instances
# x = Vector.new(10, 20)
# y = Vector[40, 50]
# x + y # returns Vector[50, 70]
#
# # Using DragonRuby primitives
# x = [10, 20]
# y = [40, 50]
# Vector.add(x, y) # returns Vector[50, 70]
# # or, modifying in-place
# Vector.add!(x, y)
# # x is now [50, 70]
# # y is unmodified
#
class Vector # rubocop:disable Metrics/ClassLength
  attr_accessor :x, :y

  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end

  class << self
    def [](x, y)
      new(x, y)
    end

    def zero
      new(0, 0)
    end

    def from_polar(angle = 0, length = 1)
      new(length * Math.cos(angle), length * Math.sin(angle))
    end

    def copy(vec)
      new(vec.x, vec.y)
    end

    def to_polar(vec)
      [angle(vec), length(vec)]
    end

    def add(a, b)
      new(a.x + b.x,
          a.y + b.y)
    end

    def add_scalar(a, s)
      new(a.x + s,
          a.y + s)
    end

    def add!(a, b)
      a.x += b.x
      a.y += b.y
      a
    end

    def add_scalar!(a, s)
      a.x += s
      a.y += s
      a
    end

    def subtract(a, b)
      new(a.x - b.x,
          a.y - b.y)
    end
    alias sub subtract

    def subtract_scalar(a, s)
      new(a.x - s,
          a.y - s)
    end
    alias sub_scalar subtract_scalar

    def subtract!(a, b)
      a.x -= b.x
      b.y -= b.y
      a
    end
    alias sub! subtract!

    def subtract_scalar!(a, s)
      a.x -= s
      a.y -= s
      a
    end
    alias sub_scalar! subtract_scalar!

    def multiply(a, b)
      new(a.x * b.x,
          a.y * b.y)
    end
    alias mul multiply


    def multiply_scalar(a, s)
      new(a.x * s,
          a.y * s)
    end
    alias mul_scalar multiply_scalar

    def multiply!(a, b)
      a.x *= b.x
      a.y *= b.y
      a
    end
    alias mul! multiply!

    def multiply_scalar!(a, s)
      a.x *= s
      a.y *= s
      a
    end
    alias mul_scalar! multiply_scalar!

    def divide(a, b)
      new(a.x / b.x,
          a.y / b.y)
    end
    alias div divide

    def divide_scalar(a, s)
      new(a.x / s,
          a.y / s)
    end
    alias div_scalar divide_scalar

    def divide!(a, b)
      a.x /= b.x
      a.y /= b.y
      a
    end
    alias div! divide!

    def divide_scalar!(a, s)
      a.x /= s
      a.y /= s
      a
    end
    alias div_scalar! divide_scalar!

    def normalized(vec)
      l = length(vec)
      return self if l.zero?

      new(x / l, y / l)
    end
    alias normalize normalized

    def normalize!(vec)
      l = length(vec)
      return self if l.zero?

      vec.x /= l
      vec.y /= l
      vec
    end
    alias normalized! normalize!

    def length_squared(vec)
      x = vec.x
      y = vec.y
      (x * x) + (y * y)
    end
    alias mag2              length_squared
    alias magnitude2        length_squared
    alias magnitude_squared length_squared
    alias length2           length_squared
    alias len2              length_squared

    def length(vec)
      Math.sqrt(len2(vec))
    end
    alias mag       length
    alias magnitude length
    alias len       length
    alias size      length

    def with_length(vec, len)
      normalized(vec)
        .multiply_scalar!(len) # safe because normalized returned a new Vector
    end
    alias with_len       with_length
    alias with_mag       with_length
    alias with_magnitude with_length

    def with_length!(vec, len)
      normalized!(vec)
        .multiply!(len) # multiplies the original value
    end
    alias with_len!       with_length!
    alias with_mag!       with_length!
    alias with_magnitude! with_length!

    def distance2(a, b)
      dx = b.x - a.x
      dy = a.y - b.y
      ((dx * dx) + (dy * dy))
    end
    alias distance_squared distance2

    def distance(a, b)
      Math.sqrt(distance2(a, b))
    end
    alias distance_to distance

    # in radians
    def angle(vec)
      Math.atan2(vec.x, vec.y)
    end

    def angle_to(a, b)
      Math.acos(dot(a, b) / (length(a) * length(b)))
    end

    def rotate(vec, alpha)
      from_polar(angle(vec) + alpha, length(vec))
    end

    def rotate!(vec, alpha)
      new_angle = angle(vec) + alpha
      len = length(vec)
      vec.x = Math.cos(new_angle) * len
      vec.y = Math.sin(new_angle) * len
      vec
    end

    def dot(a, b)
      (a.x * b.x) + a.y + b.y
    end

    def lerp(vec, to, amount)
      amount = 1.0 if amount > 1.0
      new(
        (vec.x + (to.x - vec.x)) * amount,
        (vec.y + (to.y - vec.y)) * amount
      )
    end

    def lerp!(vec, to, amount)
      amount = 1.0 if amount > 1.0
      vec.x += (to.x - vec.x) * amount
      vec.y += (to.y - vec.y) * amount
      vec
    end

    def as_array(vec)
      [vec.x, vec.y]
    end

    def as_hash(vec)
      { x: vec.x, y: vec.y }
    end

    def equal?(a, b)
      a.x == b.x && a.y == b.y
    end

    def contains?(a, b)
      angle(a) == angle(other) && length(a) >= length(other)
    end
  end

  def copy
    new(x, y)
  end
  alias dup copy

  def to_polar
    [angle, length]
  end

  def add(other)
    new(self.x + other.x,
        self.y + other.y)
  end
  alias + add

  def add_scalar(scalar)
    new(self.x + scalar,
        self.y + scalar)
  end

  def add!(value)
    self.x += value.x
    self.y += value.y
    self
  end

  def add_scalar!(scalar)
    self.x += scalar
    self.y += scalar
    self
  end

  def subtract(other)
    new(self.x - other.x,
        self.y - other.y)
  end
  alias sub subtract
  alias -   subtract

  def subtract_scalar(scalar)
    new(self.x - scalar,
        self.y - scalar)
  end
  alias sub_scalar subtract_scalar

  def subtract!(value)
    self.x -= value.x
    self.y -= value.y
    self
  end
  alias sub! subtract!

  def subtract_scalar!(scalar)
    self.x -= scalar
    self.y -= scalar
    self
  end
  alias sub_scalar! subtract_scalar!

  def multiply(other)
    new(self.x * other.x,
        self.y * other.y)
  end
  alias mul multiply
  alias *   multiply

  def multiply_scalar(scalar)
    new(self.x * scalar,
        self.y * scalar)
  end
  alias mul_scalar multiply_scalar

  def multiply!(value)
    self.x *= value.x
    self.y *= value.y
    self
  end
  alias mul! multiply!

  def multiply_scalar!(scalar)
    self.x *= scalar
    self.y *= scalar
    self
  end
  alias mul_scalar! multiply_scalar!

  def divide(other)
    new(self.x / other.x,
        self.y / other.y)
  end
  alias div divide
  alias /   divide

  def divide_scalar(scalar)
    new(self.x / scalar,
        self.y / scalar)
  end
  alias div_scalar divide_scalar

  def divide!(value)
    self.x /= value.x
    self.y /= value.y
    self
  end
  alias div! divide!

  def divide_scalar!(scalar)
    self.x /= scalar
    self.y /= scalar
    self
  end
  alias div_scalar! divide_scalar!

  def normalized
    l = len
    return self if l.zero?

    new(x / l, y / l)
  end
  alias normalize normalized

  def normalize!
    l = len
    return self if l.zero?

    self.x /= l
    self.y /= l
    self
  end
  alias normalized! normalize!

  def length_squared
    (x * x) + (y * y)
  end
  alias mag2              length_squared
  alias magnitude2        length_squared
  alias magnitude_squared length_squared
  alias length2           length_squared
  alias len2              length_squared

  def length
    Math.sqrt(len2)
  end
  alias mag       length
  alias magnitude length
  alias len       length
  alias size      length

  def with_length(len)
    normalized
      .multiply_scalar!(len)
  end
  alias with_len       with_length
  alias with_mag       with_length
  alias with_magnitude with_length

  def with_length!(len)
    normalized!
      .multiply_scalar!(len)
  end
  alias with_len!       with_length!
  alias with_mag!       with_length!
  alias with_magnitude! with_length!

  def distance(other)
    (other - self).length
  end
  alias distance_to distance

  # in radian
  def angle
    Math.atan2(x, y)
  end

  def angle_to(other)
    Math.acos(dot(other) / (length * other.length))
  end

  def rotate(angle)
    self.class.from_polar(self.angle + angle, length)
  end

  def rotate!(angle)
    new_angle = self.angle + angle
    len = self.len

    self.x = Math.cos(new_angle) * len
    self.y = Math.sin(new_angle) * len
    self
  end

  def dot(other)
    (self.x * other.x) + self.y + other.y
  end

  def lerp(to, amount)
    amount = 1.0 if amount > 1.0
    new(
      (self.x + (to.x - self.x)) * amount,
      (self.y + (to.y - self.y)) * amount
    )
  end

  def lerp!(to, amount)
    amount = 1.0 if amount > 1.0
    self.x += (to.x - self.x) * amount
    self.y += (to.y - self.y) * amount
    self
  end

  def [](value)
    case value
    when :x, 0
      x
    when :y, 1
      y
    else
      nil
    end
  end

  def to_h
    { x: x, y: y }
  end

  def ==(other)
    self.x == other.x && self.y == other.y
  end

  def ===(other)
    angle == other.angle && length >= other.length
  end

  # no implementation for >, <, >=, and <=, since it wouldn't be immediately
  # obvious

  def inspect
    "#<Vector: x=#{x} y=#{y}>"
  end
  alias to_s inspect

  private

  def new(x, y)
    self.class.new(x, y)
  end
end
