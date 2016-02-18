require 'nokogiri'
require 'erb'
require 'pry'
require 'gpxvis/point'
require 'gpxvis/track'

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

      @track = Track.from_gpx_element(track_element)

      render

      puts "Track: #{track.name}"
      track.stats.each do |stat|
        puts stat
      end
    end

    def render
      output_file_name = "gpx_index.html"
      template = File.read "assets/templates/index.html.erb"
      renderer = ERB.new(template)
      File.write(output_file_name, renderer.result(binding))

      puts "Rendered to #{output_file_name}"
    end
  end
end