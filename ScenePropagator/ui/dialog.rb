# ScenePropagator/ui/dialog.rb
require 'json'
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

      diff_service = DiffService.new(@model, options)
      diff = diff_service.compute_diff(source, targets)

      @dialog.execute_script("SPBridge.renderDiff(#{diff.to_json})")
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



