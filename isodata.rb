require 'matrix'
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

  class TempCluster
    attr_reader :cluster
    attr_reader :center
    def initialize(cluster, center)
      @cluster = cluster
      @center = center
    end
  end

  def analyze vectors

    raise ArgumentError, "Insufficient vectors." if vectors.size < @minClusterSize

    initialCluster = Cluster[*vectors]
    @clusters = Set.new [initialCluster]

    iteration = 0
    until iteration + 1 == @maxIteration
      iteration += 1

      splittingHappened = false
      until splittingHappened

        unchecked_clusters = @clusters.to_a

        tempClusters = Array.new
        @clusters.each { |cluster| tempClusters.push TempCluster.new(cluster, cluster.center) }
        # A temporary collection of centers is created since the algorithm said so.

        @clusters.each { |cluster| cluster.clear }
        vectors.each do |vector|
          nearestCluster = get_nearest_cluster(vector, tempClusters)
          nearestCluster.add vector
        end

        until unchecked_clusters.empty?

          cluster = unchecked_clusters.pop
          hasEnoughMember = cluster.size >= @minClusterSize
          next if hasEnoughMember

          @clusters.delete cluster
          tempClusters.delete cluster

          orphans = cluster.vectors
          orphans.each do |vector|
            nearestCluster = get_nearest_cluster(vector, tempClusters)
            nearestCluster.add vector
          end
        end

        if iteration >= @maxIteration
          @minClustersDistance = 0
          break
        end

        if @clusters.size > @desiredClusterCount / 2 
          break if iteration % 2 == 0 or @clusters.size >= 2 * @desiredClusterCount
        end

        overallAverageDistance = 
        unchecked_clusters = @clusters.to_a
        until unchecked_clusters.empty?

          cluster = unchecked_clusters.pop
          oversized = cluster.max_deviation > @maxDeviation
          next unless oversized
          
          if @clusters.size > @desiredClusterCount / 2 
            next if (cluster.average_distance <= @minClustersDistance or cluster.size <= 2*(@minClusterSize + 1))
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

      return @clusters if @maxPairsLumped == 0

      tooCloseClusterPairs = Array.new

      allPairs = @clusters.to_a.combination(2)
      allPairs.each do |cluster1, cluster2|
        distance = distance(cluster1.center, cluster2.center)
        tooCloseClusterPairs.add [center1, center2] if distance < @minClustersDistance
        # Should be replaced with pair
      end

      return @clusters if tooCloseClusterPairs.empty?

      sortedByDistance = tooCloseClusterPairs.sort_by { |pair| distance(pair[0].center, pair[1].center) }
      sortedByDistance.slice! @maxPairsLumped
      sortedByDistance.each do |pair|
        lump pair
      end
    end

    return @clusters
  end

  private

  def overall_average_distance
    sum = 0.0
    count = 0
    @clusters.each { |c|
      sum += c.size * c.average_distance
      count += c.size
    }
    return sum / count
  end

  def lump clusterPair
    cluster1 = clusterPair[0]
    cluster2 = clusterPair[1]
    newCluster = cluster1.merge cluster2

    @clusters.delete cluster1
    @clusters.delete cluster2
    @clusters.add newCluster
  end

  def get_nearest_cluster(vector, tempClusters)

    raise ArgumentError, 'There is no cluster.' if tempClusters.empty?
    # Should be InvalidOperation.

    nearestIndex = 0
    record = distance(tempClusters[0].center, vector)

    tempClusters.drop(1).each_index do |index|
      center = tempClusters[index].center
      if distance(center, vector) < record
        nearestIndex = index
        record = distance(center, vector)
      end
    end
    return tempClusters[nearestIndex].cluster
  end

  def distance(vector1, vector2)
    return (vector1 - vector2).magnitude
  end
end