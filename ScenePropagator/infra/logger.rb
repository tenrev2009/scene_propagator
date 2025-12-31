# ScenePropagator/infra/logger.rb

require 'json'
require 'csv'

module ScenePropagator
  class Logger
    attr_reader :entries

    LEVELS = %i[debug info warn error].freeze

    def initialize
      @entries = []
    end

    LEVELS.each do |level|
      define_method(level) do |message|
        add(level, message)
      end
    end

    def add(level, message)
      return unless LEVELS.include?(level)
      timestamp = Time.now.utc.iso8601
      @entries << { level: level, time: timestamp, message: message }
    end

    def clear
      @entries.clear
    end

    def export_json
      JSON.pretty_generate(@entries)
    end

    def export_csv
      CSV.generate(headers: true) do |csv|
        csv << %w[Time Level Message]
        @entries.each do |entry|
          csv << [entry[:time], entry[:level].to_s.upcase, entry[:message]]
        end
      end
    end

    def filter_by_level(level)
      @entries.select { |e| e[:level] == level }
    end

    def to_s
      @entries.map do |e|
        "[#{e[:time]}] #{e[:level].to_s.upcase}: #{e[:message]}"
      end.join("\n")
    end
  end
end
