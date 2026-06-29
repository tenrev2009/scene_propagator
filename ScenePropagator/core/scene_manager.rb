# encoding: UTF-8
# ScenePropagator/core/scene_manager.rb
#
# Handles creation and renaming of scenes (pages) in the active model.
module ScenePropagator
  class SceneManager
    MAX_SCENES_AT_ONCE = 500

    def initialize(model, logger)
      @model  = model
      @logger = logger
      @pages  = model.pages
    end

    # Rename an existing scene. Returns the final (validated) name.
    def rename_scene(old_name, new_name)
      new_name = new_name.to_s.strip
      raise ArgumentError, "Empty name" if new_name.empty?

      page = find_page(old_name)
      raise ArgumentError, "Scene '#{old_name}' not found" unless page

      return page.name if page.name == new_name

      if @pages.to_a.any? { |p| p.name == new_name && !p.equal?(page) }
        raise ArgumentError, "A scene named '#{new_name}' already exists"
      end

      @model.start_operation('Rename Scene', true)
      begin
        page.name = new_name
        @model.commit_operation
      rescue => e
        @model.abort_operation rescue nil
        @logger.error("Rename failed: #{e.message}")
        raise
      end

      @logger.info("Renamed scene '#{old_name}' -> '#{new_name}'")
      page.name
    end

    # Create one or more scenes.
    #
    # Options:
    #   count       - how many scenes to create (>= 1)
    #   base_name   - core name (optional, defaults to "Scene")
    #   prefix      - text prepended to each name
    #   suffix      - text appended to each name
    #   source_name - name of the scene whose properties should be inherited
    #   copy_source - when true, new scenes inherit source properties
    #
    # Returns the array of created scene names.
    def create_scenes(count:, base_name: '', prefix: '', suffix: '',
                       source_name: nil, copy_source: false)
      count = count.to_i
      count = 1 if count < 1
      count = MAX_SCENES_AT_ONCE if count > MAX_SCENES_AT_ONCE

      source = copy_source && source_name ? find_page(source_name) : nil
      if copy_source && source_name && source.nil?
        @logger.warn("Source scene '#{source_name}' not found; creating from current view")
      end

      original = @pages.selected_page
      disable_transitions
      @model.start_operation('Create Scenes', true)
      created = []

      begin
        # Activating the source page makes the current view reflect all of its
        # stored properties (camera, style, shadows, layer visibility...).
        # pages.add then captures that view into each new scene = faithful copy.
        @pages.selected_page = source if source

        count.times do |i|
          name = unique_name(build_name(base_name, prefix, suffix, i, count))
          page = @pages.add(name)
          created << page.name
        end

        @model.commit_operation
      rescue => e
        @model.abort_operation rescue nil
        @logger.error("Create scenes failed: #{e.message}")
        raise
      ensure
        @pages.selected_page = original if original && original.valid?
        restore_transitions
      end

      @logger.info("Created #{created.size} scene(s)")
      created
    end

    private

    def find_page(name)
      @pages.to_a.find { |p| p.name == name }
    end

    def build_name(base, prefix, suffix, index, count)
      base   = base.to_s.strip
      prefix = prefix.to_s
      suffix = suffix.to_s

      number = count > 1 ? (index + 1).to_s : ''
      if base.empty?
        base = 'Scene'
        number = (index + 1).to_s if number.empty?
      end

      "#{prefix}#{base}#{number}#{suffix}"
    end

    def unique_name(name)
      existing = @pages.to_a.map(&:name)
      return name unless existing.include?(name)

      i = 2
      loop do
        candidate = "#{name}-#{i}"
        return candidate unless existing.include?(candidate)
        i += 1
      end
    end

    def disable_transitions
      opts = @model.options['PageOptions']
      return unless opts
      @prev_show_transition = opts['ShowTransition']
      @prev_transition_time = opts['TransitionTime']
      opts['ShowTransition'] = false
      opts['TransitionTime'] = 0.0
    rescue => e
      @logger.warn("Could not disable transitions: #{e.message}")
    end

    def restore_transitions
      opts = @model.options['PageOptions']
      return unless opts
      opts['ShowTransition'] = @prev_show_transition unless @prev_show_transition.nil?
      opts['TransitionTime'] = @prev_transition_time unless @prev_transition_time.nil?
    rescue => e
      @logger.warn("Could not restore transitions: #{e.message}")
    end
  end
end
