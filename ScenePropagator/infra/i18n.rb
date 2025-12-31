# ScenePropagator/infra/i18n.rb

require 'yaml'

module ScenePropagator
  module I18n
    SUPPORTED_LOCALES = %w[en fr].freeze

    @translations = {}
    @locale = nil

    def self.init
      locale_code = Sketchup.get_locale[0..1].downcase
      @locale = SUPPORTED_LOCALES.include?(locale_code) ? locale_code : 'en'
      load_locale(@locale)
    end

    def self.load_locale(locale)
      path = File.join(__dir__, '..', 'locales', "#{locale}.yml")
      @translations = YAML.load_file(path)[locale] || {}
    rescue => e
      puts "[ScenePropagator::I18n] Failed to load locale #{locale}: #{e.message}"
      @translations = {}
    end

    def self.locale
      @locale || 'en'
    end

    def self.t(key, fallback = nil)
      keys = key.to_s.split('.')
      result = @translations.dig(*keys)
      result.nil? ? (fallback || key.to_s) : result
    end
  end
end

# Initialiser la langue au chargement du plugin
ScenePropagator::I18n.init
