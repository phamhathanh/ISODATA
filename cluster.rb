require 'matrix'
require 'set'

class Cluster

  attr_reader :dim
  attr_reader :vectors

  def initialize dim

    raise ArgumentError, 'Invalid dimension.' unless dim.is_a? Integer and dim > 0

    @dim = dim
    @dim.freeze

    @vectors = Set.new
  end

  def self.[] *vectors

    raise ArgumentError, 'There must be at least one vector.' if vectors.size == 0

    cluster = self.new vectors.first.size
    cluster.add vectors.first

    vectors.drop(1).each do |vector|
      cluster.add vector
    end

    return cluster
  end

  def add vector
    raise ArgumentError, 'Vector dimension does not match.' if vector.size != @dim
    @vectors.add vector
  end

  def clear
    @vectors = Set.new
  end

  private
  def clear_cache
    @center = nil
    @averageDistance = nil
    @standardDeviation = nil
    @maxDeviation = nil
  end
  public

  def center
    return @center unless @center.nil?

    zeroVector = Vector.basis(size:@dim, index:0) - Vector.basis(size:@dim, index:0)
    sum = zeroVector
    @vectors.each do |vector|
      sum += vector
    end

    center = sum / @vectors.size
  end

  def size
    return @vectors.size
  end

  def average_distance
    return @averageDistance unless @averageDistance.nil?

    sum = 0.0
    @vectors.each do |vector|
      sum += distance(vector, center)
    end

    @averageDistance = sum / @vectors.size
  end

  def standard_deviation
    return @standardDeviation unless @standardDeviation.nil?

    output = Array.new @dim
    @dim.times do |i|

      sum = 0.0
      @vectors.each do |vector|
        sum += distance(vector[i], center[i]) ** 2
      end

      output[i] = Math::sqrt(sum / @vectors.size)
    end

    return Vector.elements output
  end

  def max_deviation
    return @maxDeviation unless @maxDeviation.nil?
    return standard_deviation.max
  end

  def split

    splitIndex = max_deviation_index
    gamma = 0.6
    # No idea what it is. Some kind of coefficient.

    basis = Vector.basis(size: @dim, index: splitIndex)
    center1 = center + gamma * max_deviation * basis
    center2 = center - gamma * max_deviation * basis

    cluster1 = Cluster.new @dim
    cluster2 = Cluster.new @dim

    @vectors.each do |vector|
      if distance(vector, center1) < distance(vector, center2)
        cluster1.add vector
      else
        cluster2.add vector
      end
    end

    return Set.new [cluster1, cluster2]
  end

  def merge other

    output = Cluster.new @dim
    newVectors = @vectors.union other.vectors
    newVectors.each { |vector| output.add vector }
    return output
  end

  def hash
    return @vectors.hash
  end

  def eql? other
    return hash == other.hash
  end

  def == other
    return hash == other.hash
  end

  def to_s
    return 'Empty' if @vectors.empty?

    output = to_string vectors.first
    @vectors.drop(1).each { |vector|
      output += ', ' + to_string(vector)
    }
    return output
  end

  private

  def to_string vector
    output = '[' + vector[0].to_s
    vector.drop(1).each { |element|
      output += ', ' + element.to_s
    }
    output += ']'
  end

  def distance(vector1, vector2)
    return (vector1 - vector2).magnitude
  end

  def max_deviation_index
    return standard_deviation.collect.with_index.max[1]
  end
end