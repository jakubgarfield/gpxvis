require 'gpxvis/point'
require 'chronic_duration'

module Gpxvis
  class Track
    MOVING_THRESHOLD = 2.0

    attr_reader :name, :points

    def self.from_gpx_element(element)
      raise "element cannot be nil" if element.nil?

      name = element.at_xpath("xmlns:name").content || 'Unknown Track'

      track_segment = element.at_xpath("xmlns:trkseg")
      track_point_nodes = track_segment.xpath("xmlns:trkpt")

      points = track_point_nodes.map do |tpe|
        Point.from_gpx_element(tpe)
      end

      new(name, points)
    end

    def initialize(name, points)
      @name = name
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

    def average_moving_speed
      (((distance / 1000) / moving_duration) * 3600).round(2)
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

    class Stat < Struct.new(:name, :value, :units)
      def to_s
        s = "#{name.to_s.gsub(/_/, ' ')}: #{value}"
        s += " #{units}" if units
        s
      end
    end

    def stats
      [
        Stat.new(:distance, distance, "meters"),
        Stat.new(:duration, duration, "seconds"),
        Stat.new(:duration_human, ChronicDuration.output(duration), nil),
        Stat.new(:moving_duration, moving_duration, "seconds"),
        Stat.new(:moving_duration_human, ChronicDuration.output(moving_duration), nil),
        Stat.new(:average_moving_speed, average_moving_speed, "km/h"),
        Stat.new(:point_count, points.count, nil),
        Stat.new(:moving_point_count, moving_points.count, nil),
        Stat.new(:uphill_elevation, elevation[:uphill].round(2), "m"),
        Stat.new(:downhill_elevation, elevation[:downhill].round(2), "m"),
      ].each_with_object({}) { |s, h| h[s.name] = s }
    end
  end
end
