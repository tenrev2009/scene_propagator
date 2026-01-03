# encoding: UTF-8
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
      raise ArgumentError, "Source page missing" unless source_page
      targets = Array(target_pages).compact.reject { |p| p == source_page }
      return if targets.empty?

      # 1. Save original context
      original_page = @pages.selected_page
      
      @model.start_operation('Propagate Scenes', true)
      
      begin
        # 2. ACTIVATE SOURCE
        # We must switch to the source scene so SketchUp loads 
        # the correct hidden objects, style overrides, and active section planes.
        if @pages.selected_page != source_page
          @pages.selected_page = source_page
        end

        targets.each do |dst|
          @logger.info("Propagation #{source_page.name} -> #{dst.name}")
          copy_properties_with_view_context(source_page, dst)
        end

        @model.commit_operation
      rescue => e
        @model.abort_operation
        @logger.error("Critical error: #{e.message}")
        if e.backtrace
          @logger.error(e.backtrace.first(5).join("\n"))
        end
        raise
      ensure
        # 3. RESTORE CONTEXT
        if original_page && original_page.valid?
          @pages.selected_page = original_page
        end
      end
    end

    private

    def copy_properties_with_view_context(src, dst)
      # --- A. TAGS (LAYERS) ---
      if @options[:tags]
        # Because Source is active, layer.visible? reflects Source state
        @layers.each do |layer|
          dst.set_visibility(layer, layer.visible?)
        end
        dst.use_hidden_layers = true
      end

      # --- B. VISUAL PROPERTIES (Capture View) ---
      
      # 1. Camera
      if @options[:camera]
        update_isolated(dst, :use_camera)
      end

      # 2. Hidden Geometry
      if @options[:hidden]
        update_isolated(dst, :use_hidden)
      end

      # 3. Style & Environment
      if @options[:style]
        update_isolated(dst, :use_rendering_options)
      end

      # 4. Shadows
      if @options[:shadows]
        update_isolated(dst, :use_shadow_info)
      end

      # 5. Sections
      if @options[:sections]
        update_isolated(dst, :use_section_planes)
      end

      # 6. Axes
      if @options[:axes]
        update_isolated(dst, :use_axes)
      end

      # --- C. OTHERS (Direct Properties) ---
      if @options[:transitions]
        # FIX: SketchUp API uses 'transition_time' and 'delay_time'
        if src.respond_to?(:transition_time)
          dst.transition_time = src.transition_time 
        end
        
        # Check for delay_time (correct API name)
        if src.respond_to?(:delay_time)
          dst.delay_time = src.delay_time
        end
      end
    end

    # Updates ONE property of the scene by capturing the active view (Source)
    # without overwriting other properties already stored in the scene.
    def update_isolated(page, target_flag_symbol)
      # Map of all flags managed by scene update
      flags_map = {
        use_camera:            page.use_camera?,
        use_rendering_options: page.use_rendering_options?, # Style
        use_shadow_info:       page.use_shadow_info?,         # Shadows
        use_axes:              page.use_axes?,
        use_hidden:            page.use_hidden?,        # Hidden Geometry
        use_hidden_layers:     page.use_hidden_layers?, # Tags
        use_section_planes:    page.use_section_planes?
      }

      # 1. Disable all flags temporarily
      flags_map.keys.each { |f| page.send("#{f}=", false) }

      # 2. Enable only the target flag
      page.send("#{target_flag_symbol}=", true)

      # 3. Update (Captures the current screen state = Source)
      page.update

      # 4. Restore other flags
      flags_map.each do |flag, was_active|
        next if flag == target_flag_symbol
        page.send("#{flag}=", was_active)
      end
    end
  end
end