require 'minitest/autorun'
require 'matrix'
require './cluster'

class ClusterTest < Minitest::Test

  def test_initialization

    assert_raises ArgumentError do
      Cluster.new 0
    end

    assert_raises ArgumentError do
      Cluster.new 1.2
    end

    assert_raises ArgumentError do
      Cluster[]
    end

    assert_raises ArgumentError do
      Cluster[Vector[1, 0], Vector[1, 0, 0]]
    end
  end

  def test_add_vector

    cluster = Cluster.new 3
    cluster.add Vector[0, 1, 0]

    assert_raises ArgumentError do
      cluster.add Vector[0, 2]
    end
  end

  def test_center

    cluster = Cluster.new 2
    cluster.add Vector[0, 1]
    cluster.add Vector[2, 3]
    cluster.add Vector[1, 5]

    assert_equal(cluster.center, Vector[1, 3])
  end

  def test_average_distance

    cluster = Cluster.new 2
    cluster.add Vector[0, 1]
    cluster.add Vector[2, 3]
    cluster.add Vector[1, 5]

    assert_in_epsilon(cluster.average_distance, 1 + Math::sqrt(5) / 3)
  end

  def test_standard_deviation

    cluster = Cluster.new 2
    cluster.add Vector[0, 1]
    cluster.add Vector[2, 3]
    cluster.add Vector[1, 5]

    assert_equal(cluster.standard_deviation, Vector[1, 2] * Math::sqrt(2.0 / 3))
    assert_in_epsilon(cluster.max_deviation, 2 * Math::sqrt(6) / 3)
  end

  def test_equality

    x1 = Vector[0, 1]
    x2 = Vector[2, 6]
    x3 = Vector[1, 5]
    x4 = Vector[1, 5]

    cluster1 = Cluster[x1, x2, x3]
    cluster2 = Cluster[x1, x2, x3]
    cluster3 = Cluster[x1, x2, x4]

    assert_equal(cluster1, cluster2)
    assert_equal(cluster1, cluster3)
  end

  def test_split

    x1 = Vector[0, 1]
    x2 = Vector[2, 6]
    x3 = Vector[1, 5]

    cluster = Cluster[x1, x2, x3]

    clusters = cluster.split

    cluster1 = Cluster[x1]
    cluster2 = Cluster[x2, x3]
    expected = Set.new [cluster2, cluster1]

    assert_equal(clusters, expected)
  end

  def test_merge

    x1 = Vector[0, 1]
    x2 = Vector[2, 6]
    x3 = Vector[1, 5]
    x4 = Vector[2, 1]
    x5 = Vector[1, 3]

    cluster1 = Cluster[x1, x2, x3]
    cluster2 = Cluster[x3, x4, x5]

    cluster = cluster1.merge cluster2
    expected = Cluster[x1, x2, x3, x4, x5]
    expectedToo = Cluster[x2, x1, x3, x4, x5]

    assert_equal(cluster, expected)
  end
end