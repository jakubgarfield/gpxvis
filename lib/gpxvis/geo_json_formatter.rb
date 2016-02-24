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
          #{@tracks.flat_map(&:segments).map { |segment| track_segment_to_json(segment) }.join(", ")}
        ]
      }
      EOS
    end

    def track_segment_to_json(segment)
      <<-EOS
      {
        "type": "Feature",
        "properties": {
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
