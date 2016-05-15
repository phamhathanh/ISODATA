require 'rubygems'
require 'gosu'
require 'csv'
require './isodata'

class MyWindow < Gosu::Window

  def initialize

    @screen_width = 1280
    @screen_height = 768
    super @screen_width, @screen_height, false
    self.caption = 'ISODATA'

    @result = run_isodata
    @dot = Gosu::Image.new('dot.png', :tileable => true)

    @colorMap = Hash[@result.each_with_index.map { |c,i| [c, get_color(i)] }]
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
    x = vector[0] * 50 + 50
    y = - vector[1] * 50 + @screen_height - 50
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