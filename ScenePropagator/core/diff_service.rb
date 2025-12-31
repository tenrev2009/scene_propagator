# ScenePropagator/core/diff_service.rb

module ScenePropagator
  class DiffService
    def initialize(model, options)
      @model   = model
      @options = options # Hash de flags
    end

    def compute_diff(source_page, target_pages)
      diffs = {}

      target_pages.each do |target|
        next if source_page == target

        diff = {}
        diff[:camera]     = diff_camera(source_page, target)     if @options[:camera]
        diff[:shadows]    = diff_shadows(source_page, target)    if @options[:shadows]
        diff[:tags]       = diff_tags(source_page, target)       if @options[:tags]
        diff[:style]      = diff_style(source_page, target)      if @options[:style]
        diff[:sections]   = diff_sections(source_page, target)   if @options[:sections]
        diff[:axes]       = diff_axes(source_page, target)       if @options[:axes]
        diff[:hidden]     = diff_hidden(source_page, target)     if @options[:hidden]
        diff[:transitions]= diff_transitions(source_page, target)if @options[:transitions]

        # Ne garder que les différences non vides
        diffs[target.name] = diff.reject { |_, changes| changes.nil? || changes.empty? }
      end

      diffs
    end

    private

    def diff_camera(src, tgt)
      return unless src.camera && tgt.camera

      s = src.camera
      t = tgt.camera

      changes = {}
      changes[:eye] = [s.eye, t.eye] if s.eye != t.eye
      changes[:target] = [s.target, t.target] if s.target != t.target
      changes[:fov] = [s.fov, t.fov] if s.fov != t.fov
      changes[:perspective] = [s.perspective?, t.perspective?] if s.perspective? != t.perspective?

      changes
    end

    def diff_shadows(src, tgt)
      changes = {}
      keys = %w[
        ShadowTime Timezone DisplayShadows ShadowLight ShadowDark
        UseSunForAllShading DisplayOnGround DisplayInSky
      ]

      keys.each do |key|
        src_val = src.shadow_info[key]
        tgt_val = tgt.shadow_info[key]
        if src_val != tgt_val
          changes[key] = [src_val, tgt_val]
        end
      end

      changes
    end

    def diff_tags(src, tgt)
      changes = {}

      src_vis = src.tag_visibility
      tgt_vis = tgt.tag_visibility

      tag_names = (src_vis.keys.map(&:name) + tgt_vis.keys.map(&:name)).uniq

      tag_names.each do |tag_name|
        src_tag = src_vis.keys.find { |t| t.name == tag_name }
        tgt_tag = tgt_vis.keys.find { |t| t.name == tag_name }

        src_val = src_tag ? src_vis[src_tag] : nil
        tgt_val = tgt_tag ? tgt_vis[tgt_tag] : nil

        if src_val != tgt_val
          changes[tag_name] = [src_val, tgt_val]
        end
      end

      changes
    end

    def diff_style(src, tgt)
      s = src.style
      t = tgt.style
      return {} if s == t

      { style: [s.name, t.name] }
    end

    def diff_sections(_src, _tgt)
      # TODO: Implémentation fine selon les SectionPlane liés aux pages
      {}
    end

    def diff_axes(_src, _tgt)
      # TODO: API ne donne pas directement les axes liés à la page
      {}
    end

    def diff_hidden(_src, _tgt)
      # TODO: nécessite d’accéder aux entités masquées par page
      {}
    end

    def diff_transitions(src, tgt)
      changes = {}
      changes[:transition_time] = [src.transition_time, tgt.transition_time] if src.transition_time != tgt.transition_time
      changes[:transition_delay] = [src.transition_delay, tgt.transition_delay] if src.transition_delay != tgt.transition_delay
      changes
    end
  end
end
