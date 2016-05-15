require 'rubygems'
require 'gosu'
require 'csv'
require './isodata'

class MyWindow < Gosu::Window

  def initialize

    @dot = Gosu::Image.new('dot.png', :tileable => true)

    @screenWidth = 1280
    @screenHeight = 768
    super @screenWidth, @screenHeight, false
    self.caption = 'ISODATA'

    @result = run_isodata
    return if @result.empty?

    @colorMap = Hash.new
    @result.each_with_index.each do |cluster, index|
      @colorMap[cluster] = get_color index
    end

    firstCluster = @result.first
    firstVector = firstCluster.vectors.first
    @xMin = firstVector[0]; @xMax = firstVector[0]
    @yMin = firstVector[1]; @yMax = firstVector[1]

    @result.each do |cluster|
      cluster.vectors.each do |vector|
        @xMin = vector[0] if vector[0] < @xMin
        @xMax = vector[0] if vector[0] > @xMax
        @yMin = vector[1] if vector[1] < @yMin
        @yMax = vector[1] if vector[1] > @yMax
      end
    end
  end

  def draw
    @result.each { |cluster|

      color = @colorMap[cluster]
      cluster.vectors.each { |vector|
        screenPosition = screen_position vector
        @dot.draw(*screenPosition, 1, 1, color)
      }
    }

  end

  private

  def run_isodata

    desiredClusterCount = 5
    minClusterSize = 1
    maxDeviation = 1.5
    minClustersDistance = 4
    maxPairsLumped = 1
    maxIteration = 4

    isodata = Isodata.new(desiredClusterCount, minClusterSize, maxDeviation, minClustersDistance, maxPairsLumped, maxIteration)

    data = []
    CSV.foreach './data.csv' do |row|

      vector = Vector[*row.map { |cell| cell.to_f }]
      data.push vector
    end

    return isodata.analyze data
  end

  def screen_position vector
    image_width = 16
    image_height = 16

    realWidth = (@screenWidth - image_width).to_f
    realHeight = (@screenHeight - image_height).to_f
    xRatio = realWidth / (@xMax - @xMin)
    yRatio = realHeight / (@yMax - @yMin)
    ratio = [xRatio, yRatio].min
    x = vector[0] * ratio - @xMin + (realWidth - ratio * (@xMax - @xMin)) / 2
    y = @screenHeight - (vector[1] * ratio - @yMin + (realHeight - ratio * (@yMax - @yMin)) / 2)
    z = 0

    return [x, y, z]
  end

  def get_color index
    count = @result.size
    h = index * 360.0 / count
    s = 1
    v = 1
    Gosu::Color.from_hsv(h, s, v)
  end
end

window = MyWindow.new
window.show