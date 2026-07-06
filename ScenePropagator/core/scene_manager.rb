# encoding: UTF-8
# ScenePropagator/core/scene_manager.rb
#
# Handles creation, renaming, and bulk import/export of scenes (pages)
# in the active model.
module ScenePropagator
  class SceneManager
    MAX_SCENES_AT_ONCE = 500

    def initialize(model, logger)
      @model  = model
      @logger = logger
      @pages  = model.pages
    end

    # Rename a single existing scene. Returns the final (validated) name.
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
    # Naming scheme: prefix + index + base + suffix + index, e.g. with
    # base_name: "-", prefix: "toto", suffix: "c" and start_index: 1,
    # scenes are named "toto01-c01", "toto02-c02", ...
    #
    # Options:
    #   count        - how many scenes to create (>= 1)
    #   base_name    - literal text placed between the two indexed parts
    #   prefix       - text prepended before the first index
    #   suffix       - text placed between base and the second index
    #   start_index  - first index value (default 1)
    #   source_name  - name of the scene whose properties should be inherited
    #   copy_source  - when true, new scenes inherit source properties
    #   insert_after - name of an existing scene after which the new
    #                  sequence should be inserted (nil = append at the end)
    #
    # Returns the array of created scene names, in order.
    def create_scenes(count:, base_name: '', prefix: '', suffix: '', start_index: 1,
                       source_name: nil, copy_source: false, insert_after: nil)
      count = count.to_i
      count = 1 if count < 1
      count = MAX_SCENES_AT_ONCE if count > MAX_SCENES_AT_ONCE

      start_index = start_index.to_i
      start_index = 1 if start_index < 1
      pad_width = [2, (start_index + count - 1).to_s.length].max

      source = copy_source && source_name ? find_page(source_name) : nil
      if copy_source && source_name && source.nil?
        @logger.warn("Source scene '#{source_name}' not found; creating from current view")
      end

      anchor = insert_after ? find_page(insert_after) : nil
      insert_index = anchor ? @pages.to_a.index(anchor) + 1 : nil

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
          idx  = start_index + i
          name = unique_name(format_indexed_name(prefix, base_name, suffix, idx, pad_width))
          page = add_page_at(name, insert_index)
          created << page.name
          insert_index += 1 if insert_index
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

    # Renames an ordered list of existing scenes (by current name) using the
    # same indexed prefix/base/suffix scheme as create_scenes. Scenes are
    # renamed in the order given in names_in_order.
    #
    # Returns the array of new names, in the same order.
    def rename_scenes_bulk(names_in_order:, base_name: '', prefix: '', suffix: '', start_index: 1)
      pages_to_rename = Array(names_in_order).map { |n| find_page(n) }.compact
      raise ArgumentError, "No scenes selected" if pages_to_rename.empty?

      start_index = start_index.to_i
      start_index = 1 if start_index < 1
      pad_width = [2, (start_index + pages_to_rename.size - 1).to_s.length].max

      # Names not part of this batch must never collide with the new names.
      used = (@pages.to_a - pages_to_rename).map(&:name)
      renamed = []

      @model.start_operation('Rename Scenes (batch)', true)
      begin
        pages_to_rename.each_with_index do |page, i|
          idx = start_index + i
          candidate = format_indexed_name(prefix, base_name, suffix, idx, pad_width)
          final = unique_name_against(candidate, used)
          page.name = final
          used << final
          renamed << final
        end
        @model.commit_operation
      rescue => e
        @model.abort_operation rescue nil
        @logger.error("Bulk rename failed: #{e.message}")
        raise
      end

      @logger.info("Renamed #{renamed.size} scene(s) in batch")
      renamed
    end

    # Scene names in their current model order.
    def scene_names
      @pages.to_a.map(&:name)
    end

    # Renames existing scenes, in model order, from an ordered list of names
    # (e.g. imported from a CSV file). Only the overlapping range
    # (min(existing scenes, names given)) is renamed; extra entries on
    # either side are left untouched.
    #
    # Returns a hash with :renamed, :csv_count and :existing_count.
    def import_scene_names(names)
      pages = @pages.to_a
      names = Array(names).map { |n| n.to_s.strip }
      raise ArgumentError, "CSV file is empty" if names.reject(&:empty?).empty?

      count = [pages.size, names.size].min
      used  = pages.map(&:name)
      renamed = 0

      @model.start_operation('Import Scene Names', true)
      begin
        count.times do |i|
          candidate = names[i]
          next if candidate.empty?

          page = pages[i]
          used.delete(page.name)
          final = unique_name_against(candidate, used)
          if final != page.name
            page.name = final
            renamed += 1
          end
          used << final
        end
        @model.commit_operation
      rescue => e
        @model.abort_operation rescue nil
        @logger.error("Import scene names failed: #{e.message}")
        raise
      end

      @logger.info("Imported #{renamed} scene name(s) (csv=#{names.size}, existing=#{pages.size})")
      { renamed: renamed, csv_count: names.size, existing_count: pages.size }
    end

    private

    def find_page(name)
      @pages.to_a.find { |p| p.name == name }
    end

    def add_page_at(name, index)
      index ? @pages.add(name, index) : @pages.add(name)
    rescue ArgumentError
      # Fallback for API variants that don't accept an insertion index.
      @pages.add(name)
    end

    def format_indexed_name(prefix, base, suffix, index, pad_width)
      prefix = prefix.to_s
      base   = base.to_s
      suffix = suffix.to_s
      padded = index.to_s.rjust(pad_width, '0')

      return "Scene#{padded}" if prefix.empty? && base.empty? && suffix.empty?

      "#{prefix}#{padded}#{base}#{suffix}#{padded}"
    end

    def unique_name(name)
      unique_name_against(name, @pages.to_a.map(&:name))
    end

    def unique_name_against(name, used_names)
      return name unless used_names.include?(name)

      i = 2
      loop do
        candidate = "#{name}-#{i}"
        return candidate unless used_names.include?(candidate)
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
