const SPBridge = (() => {
  let scenes = [];
  let locale = 'en';
  let translations = {};
  let options = {};

  function loadLocale(loc) {
    translations = {
      en: {
        title: "Scene Propagator",
        select_all: "Select All",
        select_none: "Deselect All",
        invert_selection: "Invert",
        source_scene: "Source Scene",
        target_scenes: "Target Scenes",
        copy_scope: "Copy Scope",
        preset: "Preset",
        preview: "Preview",
        apply: "Apply",
        cancel: "Cancel",
        log_title: "Execution Log",
        filter: "Filter scenes...",
        manage_title: "Manage Scenes",
        rename_label: "Rename a scene",
        rename_btn: "Rename",
        rename_placeholder: "New name...",
        create_label: "Create new scenes",
        field_name: "Scene name",
        field_prefix: "Prefix (text)",
        field_suffix: "Suffix (text)",
        field_prefix_index: "Prefix index",
        field_suffix_index: "Suffix index",
        field_increment: "Increment",
        field_step: "Step",
        field_count: "Quantity",
        copy_source: "Copy properties from a source scene",
        create_btn: "Create scenes",
        insert_after: "Insert after",
        insert_after_end: "— End of list —",
        preview_prefix: "Preview: ",
        bulk_rename_label: "Rename selected scenes (checked above)",
        bulk_rename_btn: "Rename selection",
        bulk_rename_none: "No scene selected",
        csv_label: "Export / Import scene names (CSV)",
        export_csv_btn: "Export CSV",
        import_csv_btn: "Import CSV",
        csv_no_file: "Please choose a CSV file first.",
        csv_empty: "The CSV file contains no names.",
        csv_mismatch: "The CSV file contains %{csv} name(s) but there are %{existing} scene(s). Only the first %{min} will be renamed. Continue?"
      },
      fr: {
        title: "Propagateur de Scènes",
        select_all: "Tout sélectionner",
        select_none: "Aucun",
        invert_selection: "Inverser",
        source_scene: "Scène Source",
        target_scenes: "Scènes Cibles",
        copy_scope: "Propriétés à copier",
        preset: "Préréglage",
        preview: "Aperçu",
        apply: "Appliquer",
        cancel: "Annuler",
        log_title: "Journal d'exécution",
        filter: "Filtrer les scènes...",
        manage_title: "Gérer les scènes",
        rename_label: "Renommer une scène",
        rename_btn: "Renommer",
        rename_placeholder: "Nouveau nom...",
        create_label: "Créer de nouvelles scènes",
        field_name: "Nom de la scène",
        field_prefix: "Préfixe (texte)",
        field_suffix: "Suffixe (texte)",
        field_prefix_index: "Indice préfixe",
        field_suffix_index: "Indice suffixe",
        field_increment: "Incrémenter",
        field_step: "Pas",
        field_count: "Quantité",
        copy_source: "Copier les propriétés d'une scène source",
        create_btn: "Créer les scènes",
        insert_after: "Insérer après",
        insert_after_end: "— Fin de la liste —",
        preview_prefix: "Aperçu : ",
        bulk_rename_label: "Renommer les scènes sélectionnées (cochées ci-dessus)",
        bulk_rename_btn: "Renommer la sélection",
        bulk_rename_none: "Aucune scène sélectionnée",
        csv_label: "Export / Import des noms de scènes (CSV)",
        export_csv_btn: "Exporter en CSV",
        import_csv_btn: "Importer un CSV",
        csv_no_file: "Choisissez d'abord un fichier CSV.",
        csv_empty: "Le fichier CSV ne contient aucun nom.",
        csv_mismatch: "Le fichier CSV contient %{csv} nom(s) mais il y a %{existing} scène(s). Seules les %{min} premières correspondances seront renommées. Continuer ?"
      }
    }[loc] || {};
  }

  function setTexts() {
    document.getElementById('title').textContent = translations.title || 'Scene Propagator';
    document.getElementById('label-source').textContent = translations.source_scene || 'Source Scene';
    document.getElementById('label-targets').textContent = translations.target_scenes || 'Target Scenes';
    document.getElementById('label-scope').textContent = translations.copy_scope || 'Copy Scope';
    document.getElementById('label-preset').textContent = translations.preset || 'Preset';
    document.getElementById('select-all').textContent = translations.select_all || 'Select All';
    document.getElementById('select-none').textContent = translations.select_none || 'Deselect All';
    document.getElementById('invert-selection').textContent = translations.invert_selection || 'Invert';
    document.getElementById('preview-btn').textContent = `🔍 ${translations.preview || 'Preview'}`;
    document.getElementById('apply-btn').textContent = `✅ ${translations.apply || 'Apply'}`;
    document.getElementById('cancel-btn').textContent = `❌ ${translations.cancel || 'Cancel'}`;
    document.getElementById('filter-scenes').placeholder = translations.filter || 'Filter scenes...';
    document.getElementById('log-title').textContent = translations.log_title || 'Execution Log';

    // Manage Scenes section
    document.getElementById('manage-title').textContent = translations.manage_title || 'Manage Scenes';
    document.getElementById('label-rename').textContent = translations.rename_label || 'Rename a scene';
    document.getElementById('rename-input').placeholder = translations.rename_placeholder || 'New name...';
    document.getElementById('rename-btn').textContent = `✏️ ${translations.rename_btn || 'Rename'}`;
    document.getElementById('label-create').textContent = translations.create_label || 'Create new scenes';
    document.getElementById('label-copy-source').textContent = translations.copy_source || 'Copy properties from a source scene';
    document.getElementById('create-btn').textContent = `➕ ${translations.create_btn || 'Create scenes'}`;
    document.getElementById('label-insert-after').textContent = translations.insert_after || 'Insert after';

    // Field labels (shown above each input, shared between create and bulk rename)
    const fieldLabels = {
      'lbl-create-name': translations.field_name || 'Scene name',
      'lbl-create-count': translations.field_count || 'Quantity',
      'lbl-create-prefix': translations.field_prefix || 'Prefix (text)',
      'lbl-create-prefix-index': translations.field_prefix_index || 'Prefix index',
      'lbl-create-prefix-incr': translations.field_increment || 'Increment',
      'lbl-create-prefix-step': translations.field_step || 'Step',
      'lbl-create-suffix': translations.field_suffix || 'Suffix (text)',
      'lbl-create-suffix-index': translations.field_suffix_index || 'Suffix index',
      'lbl-create-suffix-incr': translations.field_increment || 'Increment',
      'lbl-create-suffix-step': translations.field_step || 'Step',
      'lbl-bulk-name': translations.field_name || 'Scene name',
      'lbl-bulk-prefix': translations.field_prefix || 'Prefix (text)',
      'lbl-bulk-prefix-index': translations.field_prefix_index || 'Prefix index',
      'lbl-bulk-prefix-incr': translations.field_increment || 'Increment',
      'lbl-bulk-prefix-step': translations.field_step || 'Step',
      'lbl-bulk-suffix': translations.field_suffix || 'Suffix (text)',
      'lbl-bulk-suffix-index': translations.field_suffix_index || 'Suffix index',
      'lbl-bulk-suffix-incr': translations.field_increment || 'Increment',
      'lbl-bulk-suffix-step': translations.field_step || 'Step'
    };
    Object.entries(fieldLabels).forEach(([id, text]) => {
      const el = document.getElementById(id);
      if (el) { el.textContent = text; }
    });

    document.getElementById('label-bulk-rename').textContent = translations.bulk_rename_label || 'Rename selected scenes (checked above)';
    document.getElementById('bulk-rename-btn').textContent = `🔁 ${translations.bulk_rename_btn || 'Rename selection'}`;

    document.getElementById('label-csv').textContent = translations.csv_label || 'Export / Import scene names (CSV)';
    document.getElementById('export-names-btn').textContent = `📤 ${translations.export_csv_btn || 'Export CSV'}`;
    document.getElementById('import-names-btn').textContent = `📥 ${translations.import_csv_btn || 'Import CSV'}`;
  }

  function fillSelect(select, names, selectedName) {
    select.innerHTML = '';
    names.forEach(name => {
      const opt = document.createElement('option');
      opt.text = name;
      opt.value = name;
      select.add(opt);
    });
    if (selectedName && names.includes(selectedName)) {
      select.value = selectedName;
    }
  }

  function fillSelectWithBlank(select, names, blankLabel, selectedValue) {
    select.innerHTML = '';
    const blankOpt = document.createElement('option');
    blankOpt.value = '';
    blankOpt.text = blankLabel;
    select.add(blankOpt);
    names.forEach(name => {
      const opt = document.createElement('option');
      opt.text = name;
      opt.value = name;
      select.add(opt);
    });
    select.value = (selectedValue && names.includes(selectedValue)) ? selectedValue : '';
  }

  function populateScenes(scenesList, preserve) {
    preserve = preserve || {};
    const names = scenesList.map(s => s.name);

    const sourceSelect = document.getElementById('source-scene');
    const sceneListDiv = document.getElementById('scene-list');
    const renameSelect = document.getElementById('rename-select');
    const createSource = document.getElementById('create-source-select');
    const insertAfter = document.getElementById('create-insert-after');

    fillSelect(sourceSelect, names, preserve.source);
    fillSelect(renameSelect, names, preserve.rename);
    fillSelect(createSource, names, preserve.createSource);
    fillSelectWithBlank(insertAfter, names, translations.insert_after_end || '— End of list —', preserve.insertAfter);

    const checkedSet = preserve.targets || new Set();
    sceneListDiv.innerHTML = '';
    scenesList.forEach(scene => {
      const label = document.createElement('label');
      label.classList.add('checkbox-label');

      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.value = scene.name;
      checkbox.classList.add('target-scene');
      checkbox.checked = checkedSet.has(scene.name);

      label.appendChild(checkbox);
      label.appendChild(document.createTextNode(scene.name));
      sceneListDiv.appendChild(label);
    });

    updateBulkPreview();
  }

  function refreshScenes(scenesList) {
    scenes = scenesList || [];
    const preserve = {
      source: document.getElementById('source-scene').value,
      rename: document.getElementById('rename-select').value,
      createSource: document.getElementById('create-source-select').value,
      insertAfter: document.getElementById('create-insert-after').value,
      targets: new Set(getSelectedTargets())
    };
    populateScenes(scenes, preserve);
    // Re-apply the current filter to the rebuilt target list.
    const filter = document.getElementById('filter-scenes');
    if (filter && filter.value) {
      filter.dispatchEvent(new Event('input'));
    }
  }

  function populateCheckboxes(presetOptions) {
    const container = document.getElementById('checkboxes');
    container.innerHTML = '';

    Object.entries(presetOptions).forEach(([key, val]) => {
      const label = document.createElement('label');
      label.classList.add('checkbox-label');

      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.name = key;
      checkbox.checked = !!val;

      label.appendChild(checkbox);
      label.appendChild(document.createTextNode(capitalize(key)));
      container.appendChild(label);
    });
  }

  function fillPresetOptions(presets, selectedName) {
    const select = document.getElementById('preset');
    select.innerHTML = '';
    presets.forEach(p => {
      const opt = document.createElement('option');
      opt.text = p;
      opt.value = p;
      select.add(opt);
    });
    if (selectedName && presets.includes(selectedName)) {
      select.value = selectedName;
    }
  }

  function populatePresets(presets) {
    const select = document.getElementById('preset');
    fillPresetOptions(presets);

    select.addEventListener('change', () => {
      if (window.sketchup && window.sketchup.sp_load_preset) {
        window.sketchup.sp_load_preset(select.value);
      }
    });

    document.getElementById('save-preset').addEventListener('click', () => {
      const name = prompt(translations.preset || "Preset name?");
      const opts = getSelectedOptions();
      if (name && window.sketchup && window.sketchup.sp_save_preset) {
        window.sketchup.sp_save_preset(JSON.stringify({ name, options: opts }));
      }
    });
  }

  // ==== Naming scheme: prefix + prefixIndex + name + suffix + suffixIndex ====
  // Mirrors ScenePropagator::SceneManager#compose_name (Ruby side).
  // The literal index text defines the padding: "0" -> 0,1,2 ; "01" -> 01,02.
  // Only used here for a live preview; the server resolves real uniqueness.
  function indexedValue(startText, increment, step, i) {
    const s = String(startText || '').trim();
    if (!s) { return ''; }
    if (!increment || !/^\d+$/.test(s)) { return s; }
    const st = Math.max(1, parseInt(step, 10) || 1);
    return String(parseInt(s, 10) + i * st).padStart(s.length, '0');
  }

  function readNamingFields(idPrefix) {
    return {
      base: document.getElementById(`${idPrefix}-base`).value,
      prefix: document.getElementById(`${idPrefix}-prefix`).value,
      suffix: document.getElementById(`${idPrefix}-suffix`).value,
      prefixIndex: document.getElementById(`${idPrefix}-prefix-index`).value,
      suffixIndex: document.getElementById(`${idPrefix}-suffix-index`).value,
      prefixIncr: document.getElementById(`${idPrefix}-prefix-incr`).checked,
      suffixIncr: document.getElementById(`${idPrefix}-suffix-incr`).checked,
      prefixStep: parseInt(document.getElementById(`${idPrefix}-prefix-step`).value, 10) || 1,
      suffixStep: parseInt(document.getElementById(`${idPrefix}-suffix-step`).value, 10) || 1
    };
  }

  function composeName(f, i) {
    const pIdx = indexedValue(f.prefixIndex, f.prefixIncr, f.prefixStep, i);
    const sIdx = indexedValue(f.suffixIndex, f.suffixIncr, f.suffixStep, i);
    const name = `${f.prefix}${pIdx}${f.base}${f.suffix}${sIdx}`;
    return name || `Scene${i + 1}`;
  }

  function computePreview(f, count) {
    if (count < 1) { return ''; }
    const first = composeName(f, 0);
    if (count === 1) { return first; }
    if (count === 2) { return `${first}, ${composeName(f, 1)}`; }
    return `${first}, ${composeName(f, 1)}, … ${composeName(f, count - 1)}`;
  }

  function updateCreatePreview() {
    const f = readNamingFields('create');
    const count = parseInt(document.getElementById('create-count').value, 10) || 1;
    const preview = computePreview(f, count);
    document.getElementById('create-preview').textContent = (translations.preview_prefix || 'Preview: ') + preview;
  }

  function updateBulkPreview() {
    const count = getSelectedTargets().length;
    const el = document.getElementById('bulk-preview');
    if (count === 0) {
      el.textContent = translations.bulk_rename_none || 'No scene selected';
      return;
    }
    const f = readNamingFields('bulk');
    el.textContent = (translations.preview_prefix || 'Preview: ') + computePreview(f, count);
  }

  // ==== CSV helpers ====
  function parseCsvNames(text) {
    const lines = text.split(/\r\n|\r|\n/).map(l => l.trim()).filter(l => l.length > 0);
    if (lines.length && /^name$/i.test(lines[0].replace(/^"|"$/g, ''))) {
      lines.shift();
    }
    return lines.map(line => {
      const firstField = line.split(',')[0];
      return firstField.replace(/^"|"$/g, '').trim();
    });
  }

  function wireManageEvents() {
    // Rename (single scene)
    document.getElementById('rename-btn').addEventListener('click', () => {
      const oldName = document.getElementById('rename-select').value;
      const newName = document.getElementById('rename-input').value.trim();
      if (!oldName || !newName) { return; }
      if (window.sketchup && window.sketchup.sp_rename_scene) {
        window.sketchup.sp_rename_scene(JSON.stringify({ old_name: oldName, new_name: newName }));
      }
    });

    // Enable/disable the source picker depending on the copy checkbox
    const copyCheckbox = document.getElementById('create-copy-source');
    const createSource = document.getElementById('create-source-select');
    copyCheckbox.addEventListener('change', () => {
      createSource.disabled = !copyCheckbox.checked;
    });

    // Create scenes
    document.getElementById('create-btn').addEventListener('click', () => {
      const f = readNamingFields('create');
      const payload = {
        base_name: f.base,
        prefix: f.prefix,
        suffix: f.suffix,
        prefix_index: f.prefixIndex,
        suffix_index: f.suffixIndex,
        prefix_increment: f.prefixIncr,
        suffix_increment: f.suffixIncr,
        prefix_step: f.prefixStep,
        suffix_step: f.suffixStep,
        count: parseInt(document.getElementById('create-count').value, 10) || 1,
        insert_after: document.getElementById('create-insert-after').value || null,
        copy_source: copyCheckbox.checked,
        source: createSource.value
      };
      if (window.sketchup && window.sketchup.sp_create_scenes) {
        window.sketchup.sp_create_scenes(JSON.stringify(payload));
      }
    });

    ['create-base', 'create-prefix', 'create-suffix', 'create-prefix-index',
     'create-suffix-index', 'create-prefix-step', 'create-suffix-step',
     'create-count'].forEach(id => {
      document.getElementById(id).addEventListener('input', updateCreatePreview);
    });
    ['create-prefix-incr', 'create-suffix-incr'].forEach(id => {
      document.getElementById(id).addEventListener('change', updateCreatePreview);
    });
    updateCreatePreview();

    // Bulk rename (uses the Target Scenes checkboxes above as the selection)
    document.getElementById('bulk-rename-btn').addEventListener('click', () => {
      const names = getSelectedTargets();
      if (names.length === 0) { return; }
      const f = readNamingFields('bulk');
      const payload = {
        names,
        base_name: f.base,
        prefix: f.prefix,
        suffix: f.suffix,
        prefix_index: f.prefixIndex,
        suffix_index: f.suffixIndex,
        prefix_increment: f.prefixIncr,
        suffix_increment: f.suffixIncr,
        prefix_step: f.prefixStep,
        suffix_step: f.suffixStep
      };
      if (window.sketchup && window.sketchup.sp_rename_scenes_bulk) {
        window.sketchup.sp_rename_scenes_bulk(JSON.stringify(payload));
      }
    });

    ['bulk-base', 'bulk-prefix', 'bulk-suffix', 'bulk-prefix-index',
     'bulk-suffix-index', 'bulk-prefix-step', 'bulk-suffix-step'].forEach(id => {
      document.getElementById(id).addEventListener('input', updateBulkPreview);
    });
    ['bulk-prefix-incr', 'bulk-suffix-incr'].forEach(id => {
      document.getElementById(id).addEventListener('change', updateBulkPreview);
    });
    document.getElementById('scene-list').addEventListener('change', updateBulkPreview);
    document.getElementById('select-all').addEventListener('click', updateBulkPreview);
    document.getElementById('select-none').addEventListener('click', updateBulkPreview);
    document.getElementById('invert-selection').addEventListener('click', updateBulkPreview);

    // Export scene names to CSV
    document.getElementById('export-names-btn').addEventListener('click', () => {
      if (window.sketchup && window.sketchup.sp_export_scene_names) {
        window.sketchup.sp_export_scene_names('');
      }
    });

    // Import scene names from CSV
    document.getElementById('import-names-btn').addEventListener('click', () => {
      const fileInput = document.getElementById('import-names-file');
      const file = fileInput.files && fileInput.files[0];
      if (!file) {
        alert(translations.csv_no_file || 'Please choose a CSV file first.');
        return;
      }
      const reader = new FileReader();
      reader.onload = () => {
        const names = parseCsvNames(String(reader.result));
        if (names.length === 0) {
          alert(translations.csv_empty || 'The CSV file contains no names.');
          return;
        }
        const existingCount = scenes.length;
        if (names.length !== existingCount) {
          const template = translations.csv_mismatch ||
            'The CSV file contains %{csv} name(s) but there are %{existing} scene(s). Only the first %{min} will be renamed. Continue?';
          const msg = template
            .replace('%{csv}', names.length)
            .replace('%{existing}', existingCount)
            .replace('%{min}', Math.min(names.length, existingCount));
          if (!confirm(msg)) { return; }
        }
        if (window.sketchup && window.sketchup.sp_import_scene_names) {
          window.sketchup.sp_import_scene_names(JSON.stringify({ names }));
        }
      };
      reader.readAsText(file);
    });
  }

  function getSelectedOptions() {
    const result = {};
    document.querySelectorAll('#checkboxes input[type="checkbox"]').forEach(cb => {
      result[cb.name] = cb.checked;
    });
    return result;
  }

  function getSelectedTargets() {
    return Array.from(document.querySelectorAll('.target-scene:checked')).map(cb => cb.value);
  }

  function wireEvents() {
    document.getElementById('apply-btn').addEventListener('click', () => {
      const payload = {
        source: document.getElementById('source-scene').value,
        targets: getSelectedTargets(),
        options: getSelectedOptions()
      };
      if (window.sketchup && window.sketchup.sp_apply) {
        window.sketchup.sp_apply(JSON.stringify(payload));
      }
    });

    document.getElementById('preview-btn').addEventListener('click', () => {
      const payload = {
        source: document.getElementById('source-scene').value,
        targets: getSelectedTargets(),
        options: getSelectedOptions()
      };
      if (window.sketchup && window.sketchup.sp_preview) {
        window.sketchup.sp_preview(JSON.stringify(payload));
      }
    });

    document.getElementById('export-log').addEventListener('click', () => {
      const format = document.getElementById('log-format').value;
      if (window.sketchup && window.sketchup.sp_export_log) {
        window.sketchup.sp_export_log(format);
      }
    });

    document.getElementById('select-all').addEventListener('click', () => {
      document.querySelectorAll('.target-scene').forEach(cb => cb.checked = true);
    });

    document.getElementById('select-none').addEventListener('click', () => {
      document.querySelectorAll('.target-scene').forEach(cb => cb.checked = false);
    });

    document.getElementById('invert-selection').addEventListener('click', () => {
      document.querySelectorAll('.target-scene').forEach(cb => cb.checked = !cb.checked);
    });

    // Filtre de scènes (simple contient)
    document.getElementById('filter-scenes').addEventListener('input', (e) => {
      const needle = e.target.value.toLowerCase();
      document.querySelectorAll('#scene-list .checkbox-label').forEach(lbl => {
        const txt = lbl.textContent.toLowerCase();
        lbl.style.display = txt.includes(needle) ? '' : 'none';
      });
    });

    document.getElementById('cancel-btn').addEventListener('click', () => {
      window.close();
    });
  }

  function capitalize(str) { return str.charAt(0).toUpperCase() + str.slice(1); }

  // ==== API exposée au code Ruby (via execute_script) ====
  function init(payload) {
    scenes  = payload.scenes || [];
    locale  = payload.locale || 'en';
    options = payload.default_preset || {};

    loadLocale(locale);
    setTexts();
    populateScenes(scenes);
    populatePresets(payload.presets || []);
    populateCheckboxes(options);
    wireEvents(); // 👉 maintenant on câble les événements quand le DOM est prêt et les données injectées
    wireManageEvents();
  }

  return {
    init,
    loadPreset: populateCheckboxes,
    refreshScenes,
    refreshPresets: presets => {
      // keep the most recently used / saved preset selected if present
      const current = document.getElementById('preset').value;
      fillPresetOptions(presets, current);
    },
    showError: msg => { alert(msg); },
    renderDiff: diff => {
      const log = document.getElementById('log-output');
      log.innerHTML = '';
      Object.entries(diff).forEach(([scene, changes]) => {
        const block = document.createElement('div');
        block.classList.add('log-entry');
        const list = Object.entries(changes).map(([k, v]) => {
          // v peut être un hash si catégorie complexe; gestion simple pour V1
          if (Array.isArray(v)) {
            return `<li>${k}: ${v[1]} → ${v[0]}</li>`;
          } else if (typeof v === 'object') {
            return `<li>${k}: ${JSON.stringify(v)}</li>`;
          } else {
            return `<li>${k}: ${v}</li>`;
          }
        }).join('');
        block.innerHTML = `<strong>${scene}</strong><ul>${list}</ul>`;
        log.appendChild(block);
      });
    },
    showSuccess: msg => { alert(msg); },
    downloadLog: (filename, content) => {
      const blob = new Blob([content], { type: 'text/plain;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = filename;
      link.click();
      setTimeout(() => URL.revokeObjectURL(link.href), 1000);
    }
  };
})();

// 🚀 Notifie Ruby que l'UI est prête
document.addEventListener('DOMContentLoaded', () => {
  if (window.sketchup && window.sketchup.sp_ui_ready) {
    window.sketchup.sp_ui_ready();
  }
});
