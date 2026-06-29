# ScenePropagator/core/diff_service.rb
# encoding: UTF-8

module ScenePropagator
  class DiffService
    def initialize(model, options, logger = nil)
      @model   = model
      @options = options # Hash de flags
      @logger  = logger
    end

    def compute_diff(source_page, target_pages)
      diffs = {}

      Array(target_pages).each do |target|
        next if source_page.nil? || target.nil? || source_page == target

        diff = {}
        diff[:camera]      = safe { diff_camera(source_page, target) }      if @options[:camera]
        diff[:shadows]     = safe { diff_shadows(source_page, target) }     if @options[:shadows]
        diff[:tags]        = safe { diff_tags(source_page, target) }        if @options[:tags]
        diff[:style]       = safe { diff_style(source_page, target) }       if @options[:style]
        diff[:sections]    = safe { diff_sections(source_page, target) }    if @options[:sections]
        diff[:axes]        = safe { diff_axes(source_page, target) }        if @options[:axes]
        diff[:hidden]      = safe { diff_hidden(source_page, target) }      if @options[:hidden]
        diff[:transitions] = safe { diff_transitions(source_page, target) } if @options[:transitions]

        # Ne garder que les différences non vides
        diffs[target.name] = diff.reject { |_, changes| changes.nil? || changes.empty? }
      end

      diffs
    end

    private

    # Wrap each diff computation so a single unsupported API call (which varies
    # across SketchUp versions) never crashes the whole preview.
    def safe
      yield
    rescue => e
      @logger&.warn("Diff skipped: #{e.message}")
      {}
    end

    def diff_camera(src, tgt)
      return {} unless src.respond_to?(:camera) && tgt.respond_to?(:camera)
      s = src.camera
      t = tgt.camera
      return {} unless s && t

      changes = {}
      changes[:eye]         = [fmt_point(s.eye), fmt_point(t.eye)]       if s.eye != t.eye
      changes[:target]      = [fmt_point(s.target), fmt_point(t.target)] if s.target != t.target
      changes[:fov]         = [s.fov, t.fov]                             if s.perspective? && t.perspective? && s.fov != t.fov
      changes[:perspective] = [s.perspective?, t.perspective?]           if s.perspective? != t.perspective?
      changes
    end

    # Page-level flags we can reliably compare across versions.
    def diff_shadows(src, tgt)
      flag_diff(src, tgt, :use_shadow_info?, 'Shadows enabled')
    end

    def diff_tags(src, tgt)
      flag_diff(src, tgt, :use_hidden_layers?, 'Tag visibility enabled')
    end

    def diff_style(src, tgt)
      flag_diff(src, tgt, :use_rendering_options?, 'Style enabled')
    end

    def diff_sections(src, tgt)
      flag_diff(src, tgt, :use_section_planes?, 'Section planes enabled')
    end

    def diff_axes(src, tgt)
      flag_diff(src, tgt, :use_axes?, 'Axes enabled')
    end

    def diff_hidden(src, tgt)
      flag_diff(src, tgt, :use_hidden?, 'Hidden geometry enabled')
    end

    def diff_transitions(src, tgt)
      changes = {}
      if src.respond_to?(:transition_time) && tgt.respond_to?(:transition_time) &&
         src.transition_time != tgt.transition_time
        changes[:transition_time] = [src.transition_time, tgt.transition_time]
      end
      # The SketchUp API exposes the delay as delay_time (not transition_delay).
      if src.respond_to?(:delay_time) && tgt.respond_to?(:delay_time) &&
         src.delay_time != tgt.delay_time
        changes[:delay_time] = [src.delay_time, tgt.delay_time]
      end
      changes
    end

    def flag_diff(src, tgt, method, label)
      return {} unless src.respond_to?(method) && tgt.respond_to?(method)
      sv = src.send(method)
      tv = tgt.send(method)
      sv == tv ? {} : { label => [sv, tv] }
    end

    def fmt_point(pt)
      return pt unless pt.respond_to?(:to_a)
      pt.to_a.map { |c| c.round(2) }
    end
  end
end
