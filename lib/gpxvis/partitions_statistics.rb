module Gpxvis
  module PartitionsStatistics
    def distance
      partitions.map(&:distance).reduce(:+)
    end

    def duration
      partitions.map(&:duration).reduce(:+)
    end

    def moving_duration
      partitions.map(&:moving_duration).reduce(:+)
    end

    def moving_points
      partitions.map(&:moving_points).reduce(:+)
    end

    def average_moving_speed
      (((distance / 1000) / moving_duration) * 3600).round(2)
    end

    def points
      partitions.map(&:points).reduce(:+)
    end

    def elevation
      partitions.map(&:elevation).reduce({ uphill: 0, downhill: 0 }) do |result, elevation|
        result[:uphill] += elevation[:uphill]
        result[:downhill] += elevation[:downhill]
        result
      end
    end
  end
end
