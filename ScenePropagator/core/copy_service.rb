# ScenePropagator/core/copy_service.rb
module ScenePropagator
  class CopyService
    def initialize(model, options, logger)
      @model   = model
      @options = options
      @logger  = logger
      @pages   = @model.pages
      @layers  = @model.layers
    end

    def apply(source_page, target_pages)
      raise ArgumentError, "Page source manquante" unless source_page
      targets = Array(target_pages).compact.reject { |p| p == source_page }
      return if targets.empty?

      @model.start_operation('Propager les scènes', true)
      begin
        targets.each { |dst| copy_to_page(source_page, dst) }
        @model.commit_operation
      rescue => e
        @model.abort_operation
        @logger.error("Échec de la propagation : #{e.class}: #{e.message}")
        @logger.error(e.backtrace.first(8).join("\n")) if e.backtrace
        raise
      end
    end

    private

    def copy_to_page(src, dst)
      @logger.info("Copie #{src.name} → #{dst.name}")

      copy_camera(src, dst)       if @options[:camera]
      copy_shadows(src, dst)      if @options[:shadows]
      copy_tags(src, dst)         if @options[:tags]
      copy_style(src, dst)        if @options[:style]
      copy_sections(src, dst)     if @options[:sections]
      copy_axes(src, dst)         if @options[:axes]
      copy_hidden_flags(src, dst) if @options[:hidden]
      copy_environment(src, dst)  if @options[:environment]
      copy_transitions(src, dst)  if @options[:transitions]
    end

    # --- Caméra ---
    def copy_camera(src, dst)
      cam = src.camera
      if cam
        @model.active_view.camera = cam
        keep = dst.use_camera?
        dst.use_camera = true
        dst.update
        dst.use_camera = keep
        @logger.debug("→ Caméra copiée")
      else
        @logger.warn("Pas de caméra sur '#{src.name}'")
      end
    rescue => e
      log_step_error('camera', e)
    end

    # --- Style ---
    def copy_style(src, dst)
      if src.use_style?
        style = src.style
        if style
          @model.styles.selected_style = style
          keep_cam = dst.use_camera?
          dst.use_camera = false
          dst.use_style  = true
          dst.update
          dst.use_camera = keep_cam
          @logger.debug("→ Style copié")
        else
          @logger.warn("Aucun style défini sur '#{src.name}'")
        end
      end
    rescue => e
      log_step_error('style', e)
    end

    # --- Ombres ---
    def copy_shadows(src, dst)
      dst.use_shadow_info = true if dst.respond_to?(:use_shadow_info=)
      if src.respond_to?(:shadow_info) && dst.respond_to?(:shadow_info)
        si_src, si_dst = src.shadow_info, dst.shadow_info
        si_src.to_h.each do |k, v|
          begin
            si_dst[k] = v
          rescue
            # Certaines clés sont en lecture seule → on ignore
          end
        end
      end
      @logger.debug("→ Ombres copiées")
    rescue => e
      log_step_error('shadows', e)
    end

    # --- Tags / Calques ---
    def copy_tags(src, dst)
      visible_names = src.layers.select { |l| src.layer_visible?(l) }.map(&:name)
      dst.layers.each do |layer|
        begin
          dst.set_visibility(layer, visible_names.include?(layer.name))
        rescue => e
          @logger.warn("Tag '#{layer.name}' sur '#{dst.name}': #{e.message}")
        end
      end
      @logger.debug("→ Tags copiés")
    rescue => e
      log_step_error('tags', e)
    end

    # --- Sections ---
    def copy_sections(src, dst)
      planes = @model.entities.grep(Sketchup::SectionPlane)
      src_active_ids = planes.select(&:active?).map { |sp| safe_plane_id(sp) }

      original_page = @pages.selected_page
      orig_active_ids = planes.select(&:active?).map { |sp| safe_plane_id(sp) }

      begin
        @pages.selected_page = dst
        dst.use_section_planes = src.use_section_planes? if dst.respond_to?(:use_section_planes=)

        planes.each do |sp|
          sp.active = src_active_ids.include?(safe_plane_id(sp))
        end

        dst.update
        @logger.debug("→ Sections copiées (plans actifs reproduits)")
      ensure
        planes.each { |sp| sp.active = orig_active_ids.include?(safe_plane_id(sp)) }
        @pages.selected_page = original_page if original_page
      end
    rescue => e
      log_step_error('sections', e)
    end

    def safe_plane_id(sp)
      sp.respond_to?(:persistent_id) ? sp.persistent_id : sp.entityID
    end

    # --- Axes ---
    def copy_axes(src, dst)
      if src.use_axes?
        ax = src.axes
        dst.use_axes = true
        dst.axes.set(ax.origin, ax.xaxis, ax.yaxis, ax.zaxis)
        @logger.debug("→ Axes copiés")
      else
        @logger.debug("Aucun axe spécifique sur '#{src.name}'")
      end
    rescue => e
      log_step_error('axes', e)
    end

    # --- Géométrie / Objets cachés / Brouillard ---
    def copy_hidden_flags(src, dst)
      dst.use_hidden_geometry = src.use_hidden_geometry? if dst.respond_to?(:use_hidden_geometry=)
      dst.use_hidden_objects  = src.use_hidden_objects?  if dst.respond_to?(:use_hidden_objects=)
      dst.use_fog             = src.use_fog?             if dst.respond_to?(:use_fog=)
      @logger.debug("→ Hidden/Guides/Fog copiés")
    rescue => e
      log_step_error('hidden', e)
    end

    # --- Environnement (ciel/sol) ---
    def copy_environment(src, dst)
      if src.respond_to?(:use_environment?) && src.use_environment?
        dst.use_environment = true if dst.respond_to?(:use_environment=)
        if dst.respond_to?(:environment=)
          dst.environment = src.environment
        end
        @logger.debug("→ Environnement copié (ciel/sol)")
      else
        @logger.debug("Aucun environnement actif sur '#{src.name}'")
      end
    rescue => e
      log_step_error('environment', e)
    end

    # --- Transitions ---
    def copy_transitions(src, dst)
      dst.transition_time  = src.transition_time  if dst.respond_to?(:transition_time=)
      dst.transition_delay = src.transition_delay if dst.respond_to?(:transition_delay=)
      @logger.debug("→ Transitions copiées")
    rescue => e
      log_step_error('transitions', e)
    end

    # --- Journalisation ---
    def log_step_error(step, e)
      @logger.error("[#{step}] #{e.class}: #{e.message}")
      @logger.error(e.backtrace.first(5).join("\n")) if e.backtrace
    end
  end
end

