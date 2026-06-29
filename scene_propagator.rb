# scene_propagator.rb - Extension loader
require 'sketchup.rb'
require 'fileutils'

module ScenePropagator
  unless file_loaded?(__FILE__)
    PLUGIN_ID = 'scene_propagator'.freeze
    PLUGIN_NAME = 'Scene Propagator'.freeze
    PLUGIN_VERSION = '1.0.1'.freeze
    PLUGIN_AUTHOR = 'tenrev - biblio3d'
    PLUGIN_URL = 'https://www.biblio3d.com'

    # Load internal files
    root = File.join(__dir__, 'ScenePropagator')
    require_relative 'ScenePropagator/infra/logger'
    require_relative 'ScenePropagator/infra/i18n'
    require_relative 'ScenePropagator/core/copy_service'
    require_relative 'ScenePropagator/core/diff_service'
    require_relative 'ScenePropagator/core/scene_manager'
    require_relative 'ScenePropagator/core/presets'
    require_relative 'ScenePropagator/ui/dialog'

    UI.menu('Extensions').add_item(PLUGIN_NAME) {
      ScenePropagator::Dialog.show
    }

    toolbar = UI::Toolbar.new(PLUGIN_NAME)
    cmd = UI::Command.new(PLUGIN_NAME) { ScenePropagator::Dialog.show }
    cmd.small_icon = File.join(root, 'assets', 'ui', 'copy.png')
    cmd.large_icon = File.join(root, 'assets', 'ui', 'copy.png')
    cmd.tooltip = PLUGIN_NAME
    cmd.status_bar_text = "Propagate scene properties"
    toolbar.add_item(cmd)
    toolbar.restore

    file_loaded(__FILE__)
  end
end
