require 'gpxvis/point'

module Gpxvis
  class TrackSegment
    MOVING_THRESHOLD = 2.0

    attr_reader :points

    def self.from_gpx_element(element)
      track_point_nodes = element.xpath("xmlns:trkpt")

      points = track_point_nodes.map do |tpe|
        Point.from_gpx_element(tpe)
      end

      new(points)
    end

    def initialize(points)
      @points = points
    end

    def distance
      @length ||= points.each_cons(2).map { |p1, p2| p1.distance_from(p2) }.reduce(:+).round(2)
    end

    def duration
      @duration ||= points.each_cons(2).map do |p1, p2|
        p2.seconds_from(p1)
      end.reduce(:+)
    end

    def moving_duration
      @moving_duration ||= moving_points.map do |p1, p2|
        p2.seconds_from(p1)
      end.reduce(:+)
    end

    def moving_points
      @moving_points ||= points.each_cons(2).select do |p1, p2|
        p1.distance_from(p2) > MOVING_THRESHOLD
      end
    end

    def elevation
      @elevation ||= (moving_points.map { |i1, i2| i1 } << moving_points.last.last)
        .map(&:ele)
        .each_cons(7)
        .map { |i| i.reduce(:+) / i.size.to_f }
        .each_cons(2)
        .map { |e1, e2| e2 - e1 }
        .reduce({ uphill: 0, downhill: 0}) do |result, elevation_delta|
          result[elevation_delta > 0 ? :uphill : :downhill] += elevation_delta
          result
        end
    end
  end
end
