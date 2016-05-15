require 'set'
require './cluster'

class Isodata

  def initialize(desiredClusterCount, minClusterSize, maxDeviation, minClustersDistance, maxPairsLumped, maxIteration)

    @desiredClusterCount = desiredClusterCount
    @minClusterSize = minClusterSize
    @maxDeviation = maxDeviation
    @minClustersDistance = minClustersDistance
    @maxPairsLumped = maxPairsLumped
    @maxIteration = maxIteration

    # No validation yet.
  end

  def analyze vectors

    raise ArgumentError, "Insufficient vectors." if vectors.size < @minClusterSize

    initialCluster = Cluster[*vectors]
    @clusters = Set.new [initialCluster]

    iteration = 1
    until iteration == @maxIteration

      splittingHappened = false
      until splittingHappened

        @clusters.each do |cluster|

          hasEnoughMember = cluster.size >= @minClusterSize
          next if hasEnoughMember

          @clusters.delete cluster

          orphans = cluster.vectors
          orphans.each do |vector|
            nearestCluster = get_nearest_cluster vector
            nearestCluster.add vector

            # A bit different from the algorithm.
          end
        end

        splittingHappened = false
        if iteration < @maxIteration

          minClustersDistance = 0
        else

          if @clusters.size <= @desiredClusterCount / 2 or not (iteration % 2 == 0 or @clusters.size >= 2 * @desiredClusterCount)

            unchecked_clusters = @clusters.to_a
            until unchecked_clusters.empty?

              cluster = unchecked_clusters.pop
              deviationIsValid = cluster.max_deviation < @maxDeviation
              next if deviationIsValid

              if @clusters.size > @desiredClusterCount / 2
                next unless cluster.average_distance > @minClustersDistance and cluster.size > 2*(@minClusterSize + 1)
              end

              # Split.
              cluster1, cluster2 = cluster.split.to_a
              unchecked_clusters.push cluster1
              unchecked_clusters.push cluster2

              @clusters.delete cluster
              @clusters.add cluster1
              @clusters.add cluster2

              splittingHappened = true
            end
          end
        end
      end

      return @clusters if @maxPairsLumped == 0

      tooCloseClusterPairs = Array.new
      all_pairs_of_clusters.each do |cluster1, cluster2|

        distance = distance(cluster1.center, cluster2.center)
        tooCloseClusterPairs.add [center1, center2] if distance < @minClustersDistance
        # Should be replaced with pair
      end

      return @clusters if tooCloseClusterPairs.empty?

      tooCloseClusterPairs.slice! @maxPairsLumped
      tooCloseClusterPairs.each do |pair|
        lump pair
      end
    end

    return @clusters
  end

  private

  def create_random_clusters

  end

  def lump clusters


  end

  def get_nearest_cluster vector

    raise ArgumentError, 'There is no cluster.' if @clusters.empty?
    # Should be InvalidOperation.

    clusters = @clusters.to_a
    nearest = clusters.first
    @clusters.drop(1).each do |cluster|
      nearest = cluster if distance(cluster.center, vector) < distance(nearest.center, vector)
    end
  end

  def all_pairs_of_clusters


  end

  def distance(vector1, vector2)
    return (vector1 - vector2).magnitude
  end
end