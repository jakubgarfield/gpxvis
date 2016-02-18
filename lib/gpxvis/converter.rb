require 'gpxvis/point'
require 'gpxvis/track'
require 'gpxvis/renderer'
require 'nokogiri'

module Gpxvis
  class Converter
    attr_accessor :file_name, :gpx_document, :track

    def initialize(file_name)
      @file_name = file_name
    end

    def process
      puts "Processing #{file_name}"

      @gpx_document = File.open(file_name) { |f| Nokogiri::XML(f) }

      track_element = gpx_document.xpath("//xmlns:trk").first
      raise "No 'trk' element found in #{file_name}" unless track_element

      @track = Track.from_gpx_element(track_element)

      output_file_name = "gpx_index.html"
      Renderer.new(track).render(output_file_name)

      puts "#{track.name}"
      track.stats.each do |name, stat|
        puts "\t#{stat}"
      end
    end
  end
end