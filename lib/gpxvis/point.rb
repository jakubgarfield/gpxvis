require 'haversine'

module Gpxvis
  class Point < Struct.new(:lat, :lon, :time, :ele)
    def self.from_gpx_element(element)
      lat = element.attr('lat').to_f
      lon = element.attr('lon').to_f
      ele = element.at_xpath('xmlns:ele').content.to_f
      time = DateTime.parse(element.at_xpath('xmlns:time').content)

      new(lat, lon, time, ele)
    end

    def distance_from(other_point)
      return nil if other_point.nil?

      Haversine.distance(lat, lon, other_point.lat, other_point.lon).to_meters
    end
  end
end