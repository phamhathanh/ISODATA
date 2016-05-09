require 'minitest/autorun'
require 'set'
require 'matrix'
require './isodata'
require './cluster'

class CodeTest < Minitest::Test

  def test_analyzation
    
    desiredClusterCount = 2
    minClusterSize = 1
    maxDeviation = 1.5
    minClustersDistance = 4
    maxPairsLumped = 0
    maxIteration = 4

    isodata = Isodata.new(desiredClusterCount, minClusterSize, maxDeviation, minClustersDistance, maxPairsLumped, maxIteration)

    x1 = Vector[0, 0]; x2 = Vector[1, 0]; x3 = Vector[0, 1]; x4 = Vector[1, 1]; x5 = Vector[2, 1]
    x6 = Vector[1, 2]; x7 = Vector[2, 2]; x8 = Vector[2, 3]; x9 = Vector[6, 6]; x10 = Vector[7, 6]
    x11 = Vector[8, 6]; x12 = Vector[6, 7]; x13 = Vector[7, 7]; x14 = Vector[8, 7]; x15 = Vector[9, 7]
    x16 = Vector[7, 8]; x17 = Vector[8, 8]; x18 = Vector[9, 8]; x19 = Vector[10, 8]; x20 = Vector[11, 8]

    data = [ x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20 ]

    result = isodata.analyze data

    cluster1 = Cluster[ x1 , x2, x3, x4, x5, x6, x7, x8 ]
    cluster2 = Cluster[ x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20 ]
    
    expectedResult = Set.new [cluster1, cluster2]

    assert_equal(expectedResult, result)
  end
end