require 'gpxvis/point'
require 'gpxvis/track_segment'
require 'gpxvis/track'

module Gpxvis
  class GeoJsonFormatter
    def initialize(tracks)
      @tracks = tracks
    end

    def format
      track_to_json(@tracks.first)
    end

    private
    def track_to_json(track)
      <<-EOS
      {
        "type": "FeatureCollection",
        "properties": {
          "distance": #{track.distance},
          "duration": #{track.duration},
          "moving_duration": #{track.moving_duration},
          "average_moving_speed": #{track.average_moving_speed},
          "uphill_elevation": #{track.elevation[:uphill]},
          "downhill_elevation": #{track.elevation[:downhill]}
        },
        "features": [
          #{track.segments.map { |segment| track_segment_to_json(segment) }.join(", ")}
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
  end
end
