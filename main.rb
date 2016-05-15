require 'rubygems'
require 'gosu'
require 'csv'
require './isodata'

class MyWindow < Gosu::Window

  def initialize

data_from_lrn_file 'WingNut.lrn'
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

    desiredClusterCount = 2
    minClusterSize = 1
    maxDeviation = 3
    minClustersDistance = 2
    maxPairsLumped = 1
    maxIteration = 3

    isodata = Isodata.new(desiredClusterCount, minClusterSize, maxDeviation, minClustersDistance, maxPairsLumped, maxIteration)

    data = data_from_lrn_file 'data/Lol.lrn'
    return isodata.analyze data
  end

  def data_from_lrn_file filePath
    output = []
    File.open filePath do |file|
      file.each_line.drop(4).each do |line|
        cells = line.split("\t")
        next if cells.size != 3
        output.push Vector[cells[1].to_f, cells[2].to_f]
      end
    end
    return output
  end

  def screen_position vector
    image_width = 16
    image_height = 16
    margin = 16

    realWidth = (@screenWidth - image_width - 2*margin).to_f
    realHeight = (@screenHeight - image_height - 2*margin).to_f
    xRatio = realWidth / (@xMax - @xMin)
    yRatio = realHeight / (@yMax - @yMin)
    ratio = [xRatio, yRatio].min
    x = (vector[0] - @xMin) * ratio + (realWidth - ratio * (@xMax - @xMin)) / 2 + margin
    y = -((vector[1] - @yMin) * ratio + (realHeight - ratio * (@yMax - @yMin)) / 2) + realHeight + margin
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