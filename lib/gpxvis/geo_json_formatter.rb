require 'gpxvis/point'
require 'gpxvis/track_segment'
require 'gpxvis/track'

module Gpxvis
  class GeoJsonFormatter
    include PartitionsStatistics

    def initialize(tracks)
      @tracks = tracks
    end

    def format
      <<-EOS
      {
        "type": "FeatureCollection",
        "properties": {
          "distance": #{distance},
          "duration": #{duration},
          "moving_duration": #{moving_duration},
          "average_moving_speed": #{average_moving_speed},
          "uphill_elevation": #{elevation[:uphill]},
          "downhill_elevation": #{elevation[:downhill]}
        },
        "features": [
          #{formatted_track_segments.join(", ")}
        ]
      }
      EOS
    end

    def formatted_track_segments
      @tracks.map do |track|
        track.segments.each_with_index.map do |segment, index|
          name = track.name + (track.segments.length > 1 ? " (pt. #{index + 1})" : "")
          track_segment_to_json(segment, name)
        end
      end.flatten
    end

    def track_segment_to_json(segment, name)
      <<-EOS
      {
        "type": "Feature",
        "properties": {
          "name": "#{name}",
          "distance": #{segment.distance},
          "duration": #{segment.duration},
          "moving_duration": #{segment.moving_duration},
          "uphill_elevation": #{segment.elevation[:uphill]},
          "downhill_elevation": #{segment.elevation[:downhill]}
        },
        "geometry": { "type": "MultiLineString", "coordinates": [[
          #{segment.points.map { |p| "[#{p.lon}, #{p.lat}, #{p.ele}]"}.join(", ")}
        ]]}
      }
      EOS
    end

    private
    def partitions
      @tracks
    end
  end
end
