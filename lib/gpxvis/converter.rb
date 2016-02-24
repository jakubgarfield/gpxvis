require 'gpxvis/point'
require 'gpxvis/track'
require 'gpxvis/renderer'
require 'gpxvis/geo_json_formatter'
require 'nokogiri'

module Gpxvis
  class Converter
    attr_accessor :file_name, :gpx_document, :track

    def initialize(file_names)
      @file_names = file_names
    end

    def process
      output_file_name = "gpx_index.html"
      tracks = @file_names.map { |file_name| track_from_file(file_name) }
      Renderer.new(tracks).render(output_file_name)
    end

    private
    def track_from_file(file_name)
      puts "Processing #{file_name}"

      @gpx_document = File.open(file_name) { |f| Nokogiri::XML(f) }

      track_element = gpx_document.xpath("//xmlns:trk").first
      raise "No 'trk' element found in #{file_name}" unless track_element

      track = Track.from_gpx_element(track_element)

      puts "#{track.name}"
      track.stats.each do |name, stat|
        puts "\t#{stat}"
      end

      track
    end
  end
end
