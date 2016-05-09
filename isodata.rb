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
  end

  def analyze vectors

    raise ArgumentError, "Insufficient vectors." if vectors.size < @minClusterSize

    iteration = 1

    @clusters = Array.new vectors

    do
      averageDistance = clusters.first.average_distance

      splittingHappened = false
      if iteration >= @maxIteration

        minClustersDistance = 0
        lump
      else

        if @clusters.size > @desiredClusterCount / 2

          if iteration % 2 == 0 or @clusters.size >= 2 * @desiredClusterCount

            lump
          end
        else

          unchecked_clusters = @clusters.clone
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
            @clusters.push cluster1
            @clusters.push cluster2

            splittingHappened = true
          end
        end
      end

    while splittingHappened

    # Last 2 pages go here.
    # May be one more loop is needed.
  end

  private

  def create_random_clusters

  end

  def lump

  end

  def get_nearest_center
    
  end
end