# ScenePropagator/core/presets.rb

require 'json'
require 'fileutils'

module ScenePropagator
  class Presets
    PRESET_DIR = File.join(
      Sketchup.find_support_file('Plugins'),
      'ScenePropagator',
      'presets'
    )

    DEFAULT_PRESETS = {
      'Tout' => {
        camera: true, tags: true, sections: true, style: true,
        shadows: true, axes: true, hidden: true, transitions: true
      },
      'Visuel' => {
        camera: false, tags: false, sections: false,
        style: true, shadows: true, axes: false, hidden: false, transitions: false
      },
      'Organisation' => {
        camera: false, tags: true, sections: true,
        style: false, shadows: false, axes: false, hidden: true, transitions: false
      },
      'Caméra seule' => {
        camera: true, tags: false, sections: false,
        style: false, shadows: false, axes: false, hidden: false, transitions: false
      }
    }.freeze

    def initialize(logger)
      @logger = logger
      ensure_dir
    end

    def ensure_dir
      FileUtils.mkdir_p(PRESET_DIR) unless Dir.exist?(PRESET_DIR)
    rescue => e
      @logger.error("Impossible de créer le dossier des préréglages: #{e.message}")
    end

    def list_presets
      presets = DEFAULT_PRESETS.keys
      Dir.glob(File.join(PRESET_DIR, '*.json')).each do |file|
        name = File.basename(file, '.json')
        presets << name unless presets.include?(name)
      end
      presets
    end

    def load_preset(name)
      if DEFAULT_PRESETS.key?(name)
        DEFAULT_PRESETS[name]
      else
        path = File.join(PRESET_DIR, "#{name}.json")
        if File.exist?(path)
          JSON.parse(File.read(path), symbolize_names: true)
        else
          @logger.warn("Préréglage '#{name}' introuvable, fallback par défaut")
          DEFAULT_PRESETS['Tout']
        end
      end
    rescue => e
      @logger.error("Erreur chargement préréglage #{name}: #{e.message}")
      DEFAULT_PRESETS['Tout']
    end

    def save_preset(name, options)
      path = File.join(PRESET_DIR, "#{name}.json")
      json = JSON.pretty_generate(options.merge(version: ScenePropagator::PLUGIN_VERSION))
      File.write(path, json)
      @logger.info("Préréglage '#{name}' sauvegardé")
      true
    rescue => e
      @logger.error("Impossible de sauvegarder le préréglage #{name}: #{e.message}")
      false
    end
  end
end
