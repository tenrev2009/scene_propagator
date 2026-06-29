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
        create_base: "Base name (optional)",
        create_prefix: "Prefix",
        create_suffix: "Suffix",
        copy_source: "Copy properties from a source scene",
        create_btn: "Create scenes"
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
        create_base: "Nom de base (optionnel)",
        create_prefix: "Préfixe",
        create_suffix: "Suffixe",
        copy_source: "Copier les propriétés d'une scène source",
        create_btn: "Créer les scènes"
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
    document.getElementById('create-base').placeholder = translations.create_base || 'Base name (optional)';
    document.getElementById('create-prefix').placeholder = translations.create_prefix || 'Prefix';
    document.getElementById('create-suffix').placeholder = translations.create_suffix || 'Suffix';
    document.getElementById('label-copy-source').textContent = translations.copy_source || 'Copy properties from a source scene';
    document.getElementById('create-btn').textContent = `➕ ${translations.create_btn || 'Create scenes'}`;
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

  function populateScenes(scenesList, preserve) {
    preserve = preserve || {};
    const names = scenesList.map(s => s.name);

    const sourceSelect = document.getElementById('source-scene');
    const sceneListDiv = document.getElementById('scene-list');
    const renameSelect = document.getElementById('rename-select');
    const createSource = document.getElementById('create-source-select');

    fillSelect(sourceSelect, names, preserve.source);
    fillSelect(renameSelect, names, preserve.rename);
    fillSelect(createSource, names, preserve.createSource);

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
  }

  function refreshScenes(scenesList) {
    scenes = scenesList || [];
    const preserve = {
      source: document.getElementById('source-scene').value,
      rename: document.getElementById('rename-select').value,
      createSource: document.getElementById('create-source-select').value,
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

  function wireManageEvents() {
    // Rename
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
      const payload = {
        base_name: document.getElementById('create-base').value,
        prefix: document.getElementById('create-prefix').value,
        suffix: document.getElementById('create-suffix').value,
        count: parseInt(document.getElementById('create-count').value, 10) || 1,
        copy_source: copyCheckbox.checked,
        source: createSource.value
      };
      if (window.sketchup && window.sketchup.sp_create_scenes) {
        window.sketchup.sp_create_scenes(JSON.stringify(payload));
      }
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
