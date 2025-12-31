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
        filter: "Filter scenes..."
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
        filter: "Filtrer les scènes..."
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
  }

  function populateScenes(scenesList) {
    const sourceSelect = document.getElementById('source-scene');
    const sceneListDiv = document.getElementById('scene-list');
    sourceSelect.innerHTML = '';
    sceneListDiv.innerHTML = '';

    scenesList.forEach(scene => {
      const opt = document.createElement('option');
      opt.text = scene.name;
      sourceSelect.add(opt);

      const label = document.createElement('label');
      label.classList.add('checkbox-label');

      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.value = scene.name;
      checkbox.classList.add('target-scene');

      label.appendChild(checkbox);
      label.appendChild(document.createTextNode(scene.name));
      sceneListDiv.appendChild(label);
    });
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

  function populatePresets(presets) {
    const select = document.getElementById('preset');
    select.innerHTML = '';
    presets.forEach(p => {
      const opt = document.createElement('option');
      opt.text = p;
      opt.value = p;
      select.add(opt);
    });

    select.addEventListener('change', () => {
      if (window.sketchup && window.sketchup.sp_load_preset) {
        window.sketchup.sp_load_preset(select.value);
      }
    });

    document.getElementById('save-preset').addEventListener('click', () => {
      const name = prompt("Nom du préréglage ?");
      const opts = getSelectedOptions();
      if (name && window.sketchup && window.sketchup.sp_save_preset) {
        window.sketchup.sp_save_preset(JSON.stringify({ name, options: opts }));
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
  }

  return {
    init,
    loadPreset: populateCheckboxes,
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
