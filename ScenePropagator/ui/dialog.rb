# ScenePropagator/ui/dialog.rb
require 'json'
require 'csv'
require 'sketchup.rb'

module ScenePropagator
  module Dialog
    extend self

    def show
      @logger  = Logger.new
      @model   = Sketchup.active_model
      @pages   = @model.pages.to_a
      @presets = Presets.new(@logger)
      @i18n    = I18n

      if @pages.empty?
        UI.messagebox(@i18n.t('messages.no_scene'))
        return
      end

      if @dialog.nil? || !@dialog.visible?
        create_dialog
      end

      @dialog.show
      # Le JS pingera sp_ui_ready quand le DOM sera prêt → on injectera les données à ce moment
    end

    def create_dialog
      @dialog = UI::HtmlDialog.new(
        dialog_title: I18n.t('ui.dialog.title'),
        preferences_key: 'ScenePropagator',
        scrollable: true,
        resizable: true,
        width: 700,
        height: 600,
        style: UI::HtmlDialog::STYLE_DIALOG
      )

      html_path = File.join(__dir__, '..', 'assets', 'ui', 'index.html')
      @dialog.set_file(html_path)

      # JS → Ruby : la page est prête, on peut envoyer les données
      @dialog.add_action_callback('sp_ui_ready') do |_ctx|
        populate_initial_data
      end

      @dialog.add_action_callback('sp_apply') do |_action_context, payload|
        apply_changes(JSON.parse(payload, symbolize_names: true))
      end

      @dialog.add_action_callback('sp_preview') do |_action_context, payload|
        preview_changes(JSON.parse(payload, symbolize_names: true))
      end

      @dialog.add_action_callback('sp_export_log') do |_action_context, format|
        export_log(format)
      end

      @dialog.add_action_callback('sp_load_preset') do |_ctx, preset_name|
        options = @presets.load_preset(preset_name)
        @dialog.execute_script("SPBridge.loadPreset(#{options.to_json})")
      end

      @dialog.add_action_callback('sp_save_preset') do |_ctx, payload|
        data = JSON.parse(payload, symbolize_names: true)
        @presets.save_preset(data[:name], data[:options])
        @dialog.execute_script("SPBridge.refreshPresets(#{@presets.list_presets.to_json})")
      end

      @dialog.add_action_callback('sp_rename_scene') do |_ctx, payload|
        data = JSON.parse(payload, symbolize_names: true)
        rename_scene(data[:old_name], data[:new_name])
      end

      @dialog.add_action_callback('sp_create_scenes') do |_ctx, payload|
        data = JSON.parse(payload, symbolize_names: true)
        create_scenes(data)
      end

      @dialog.add_action_callback('sp_rename_scenes_bulk') do |_ctx, payload|
        data = JSON.parse(payload, symbolize_names: true)
        rename_scenes_bulk(data)
      end

      @dialog.add_action_callback('sp_export_scene_names') do |_ctx, _payload|
        export_scene_names
      end

      @dialog.add_action_callback('sp_import_scene_names') do |_ctx, payload|
        data = JSON.parse(payload, symbolize_names: true)
        import_scene_names(data[:names])
      end
    end

    def populate_initial_data
      scenes_data = @pages.map { |p| { name: p.name } }

      payload = {
        scenes: scenes_data,
        presets: @presets.list_presets,
        locale: I18n.locale,
        default_preset: @presets.load_preset('Tout')
      }

      @dialog.execute_script("SPBridge.init(#{payload.to_json})")
    end

    def apply_changes(data)
      source_name  = data[:source]
      target_names = data[:targets]
      options      = data[:options].transform_keys(&:to_sym)

      source  = @pages.find { |p| p.name == source_name }
      targets = @pages.select { |p| target_names.include?(p.name) }

      service = CopyService.new(@model, options, @logger)
      service.apply(source, targets)

      message = I18n.t('messages.success_applied').gsub('%{count}', targets.size.to_s)
      @dialog.execute_script("SPBridge.showSuccess(#{message.to_json})")
    rescue => e
      bt = e.backtrace ? e.backtrace.first(5).join("\\n") : "no backtrace"
      @logger.error("Apply failed: #{e.class}: #{e.message}\n#{bt}")
      UI.messagebox("#{I18n.t('messages.error_propagation')}\n\n#{e.class}: #{e.message}\n#{bt}")
    end

    def preview_changes(data)
      source_name  = data[:source]
      target_names = data[:targets]
      options      = data[:options].transform_keys(&:to_sym)

      source  = @pages.find { |p| p.name == source_name }
      targets = @pages.select { |p| target_names.include?(p.name) }

      diff_service = DiffService.new(@model, options, @logger)
      diff = diff_service.compute_diff(source, targets)

      @dialog.execute_script("SPBridge.renderDiff(#{diff.to_json})")
    end

    def rename_scene(old_name, new_name)
      manager    = SceneManager.new(@model, @logger)
      final_name = manager.rename_scene(old_name, new_name)
      @pages     = @model.pages.to_a
      refresh_scenes
      msg = I18n.t('messages.scene_renamed').gsub('%{name}', final_name)
      @dialog.execute_script("SPBridge.showSuccess(#{msg.to_json})")
    rescue => e
      @logger.error("Rename failed: #{e.class}: #{e.message}")
      @dialog.execute_script("SPBridge.showError(#{e.message.to_json})")
    end

    def create_scenes(data)
      manager = SceneManager.new(@model, @logger)
      created = manager.create_scenes(
        count:        data[:count],
        base_name:    data[:base_name],
        prefix:       data[:prefix],
        suffix:       data[:suffix],
        start_index:  data[:start_index],
        source_name:  data[:source],
        copy_source:  data[:copy_source],
        insert_after: data[:insert_after]
      )
      @pages = @model.pages.to_a
      refresh_scenes
      msg = I18n.t('messages.scenes_created').gsub('%{count}', created.size.to_s)
      @dialog.execute_script("SPBridge.showSuccess(#{msg.to_json})")
    rescue => e
      @logger.error("Create scenes failed: #{e.class}: #{e.message}")
      @dialog.execute_script("SPBridge.showError(#{e.message.to_json})")
    end

    def rename_scenes_bulk(data)
      manager = SceneManager.new(@model, @logger)
      renamed = manager.rename_scenes_bulk(
        names_in_order: data[:names],
        base_name:      data[:base_name],
        prefix:         data[:prefix],
        suffix:         data[:suffix],
        start_index:    data[:start_index]
      )
      @pages = @model.pages.to_a
      refresh_scenes
      msg = I18n.t('messages.scenes_renamed_bulk').gsub('%{count}', renamed.size.to_s)
      @dialog.execute_script("SPBridge.showSuccess(#{msg.to_json})")
    rescue => e
      @logger.error("Bulk rename failed: #{e.class}: #{e.message}")
      @dialog.execute_script("SPBridge.showError(#{e.message.to_json})")
    end

    def export_scene_names
      manager = SceneManager.new(@model, @logger)
      names = manager.scene_names
      csv = CSV.generate { |c| names.each { |n| c << [n] } }
      @dialog.execute_script("SPBridge.downloadLog('scene_names.csv', #{csv.to_json})")
    rescue => e
      @logger.error("Export scene names failed: #{e.class}: #{e.message}")
    end

    def import_scene_names(names)
      manager = SceneManager.new(@model, @logger)
      result  = manager.import_scene_names(names)
      @pages  = @model.pages.to_a
      refresh_scenes
      msg = I18n.t('messages.scenes_imported')
               .gsub('%{renamed}', result[:renamed].to_s)
               .gsub('%{csv}', result[:csv_count].to_s)
               .gsub('%{existing}', result[:existing_count].to_s)
      @dialog.execute_script("SPBridge.showSuccess(#{msg.to_json})")
    rescue => e
      @logger.error("Import scene names failed: #{e.class}: #{e.message}")
      @dialog.execute_script("SPBridge.showError(#{e.message.to_json})")
    end

    def refresh_scenes
      scenes_data = @pages.map { |p| { name: p.name } }
      @dialog.execute_script("SPBridge.refreshScenes(#{scenes_data.to_json})")
    end

    def export_log(format)
      case format
      when 'csv'
        data = @logger.export_csv
        @dialog.execute_script("SPBridge.downloadLog('log.csv', #{data.to_json})")
      when 'json'
        data = @logger.export_json
        @dialog.execute_script("SPBridge.downloadLog('log.json', #{data.to_json})")
      end
    end
  end
end



