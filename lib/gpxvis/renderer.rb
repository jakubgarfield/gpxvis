require 'erb'

module Gpxvis
  class Renderer
    attr_accessor :track

    def initialize(tracks)
      @geo_json = GeoJsonFormatter.new(tracks).format
    end

    def render(output_file)
      template = File.read "assets/templates/index.html.erb"
      erb_renderer = ERB.new(template)
      File.write(output_file, erb_renderer.result(binding))

      puts "Rendered to #{output_file}"
    end
  end
end
