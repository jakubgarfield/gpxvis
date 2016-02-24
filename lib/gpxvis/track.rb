require 'gpxvis/point'
require 'gpxvis/track_segment'
require 'gpxvis/partitions_statistics'
require 'chronic_duration'

module Gpxvis
  class Track
    include PartitionsStatistics

    attr_reader :name, :segments

    def self.from_gpx_element(element)
      name = element.at_xpath("xmlns:name").content || 'Unknown Track'
      track_segments = element.xpath("xmlns:trkseg").map { |e| TrackSegment.from_gpx_element(e) }

      new(name, track_segments)
    end

    def initialize(name, segments)
      @name = name
      @segments = segments
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
        Stat.new(:name, name, nil),
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

    private
    def partitions
      @segments
    end
  end
end
