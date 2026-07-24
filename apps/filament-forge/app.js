// ─── STATE ───
let ofdBrands = [];
let ofdFilaments = [];
let selectedFilament = null;
let currentIntent = 'quality';
let modelData = null;
let apiKey = ''; // handled by server-side proxy

// ─── PRINTER SPECS DATABASE ───
const PRINTER_SPECS = {
  'bambu-p2s': { name: 'Bambu Lab P2S', maxSpeed: 500, maxAccel: 20000, maxVolFlow: 32, hasChamber: false, bedType: 'textured PEI' },
  'bambu-p1s': { name: 'Bambu Lab P1S', maxSpeed: 500, maxAccel: 20000, maxVolFlow: 32, hasChamber: true, bedType: 'textured PEI' },
  'bambu-p1p': { name: 'Bambu Lab P1P', maxSpeed: 500, maxAccel: 20000, maxVolFlow: 32, hasChamber: false, bedType: 'cool plate' },
  'bambu-x1c': { name: 'Bambu Lab X1C', maxSpeed: 500, maxAccel: 20000, maxVolFlow: 32, hasChamber: true, bedType: 'textured PEI' },
  'bambu-a1': { name: 'Bambu Lab A1', maxSpeed: 500, maxAccel: 10000, maxVolFlow: 28, hasChamber: false, bedType: 'textured PEI' },
  'bambu-a1-mini': { name: 'Bambu Lab A1 Mini', maxSpeed: 500, maxAccel: 10000, maxVolFlow: 28, hasChamber: false, bedType: 'textured PEI' },
};

// ─── INIT ───
document.addEventListener('DOMContentLoaded', () => {
  loadOFD();
  loadSavedConfig();

  // Drag and drop
  const uz = document.getElementById('uploadZone');
  uz.addEventListener('dragover', e => { e.preventDefault(); uz.style.borderColor = 'var(--accent)'; });
  uz.addEventListener('dragleave', () => { uz.style.borderColor = ''; });
  uz.addEventListener('drop', e => {
    e.preventDefault();
    uz.style.borderColor = '';
    if (e.dataTransfer.files.length) {
      document.getElementById('fileInput').files = e.dataTransfer.files;
      handleFileUpload({ target: { files: e.dataTransfer.files }});
    }
  });
});

// ─── OFD LOADING ───
async function loadOFD() {
  const dot = document.getElementById('ofdDot');
  const txt = document.getElementById('ofdText');
  try {
    const [brandsRes, filamentsRes] = await Promise.all([
      fetch('https://api.openfilamentdatabase.org/csv/brands.csv'),
      fetch('https://api.openfilamentdatabase.org/csv/filaments.csv')
    ]);

    if (!brandsRes.ok || !filamentsRes.ok) throw new Error('Failed to fetch OFD data');

    const brandsCSV = await brandsRes.text();
    const filamentsCSV = await filamentsRes.text();

    ofdBrands = parseCSV(brandsCSV);
    ofdFilaments = parseCSV(filamentsCSV);

    // Build brand lookup
    const brandMap = {};
    ofdBrands.forEach(b => { brandMap[b.id] = b.name; });

    // Enrich filaments with brand name
    ofdFilaments.forEach(f => {
      f._brandName = brandMap[f.brand_id] || 'Unknown';
    });

    dot.className = 'dot loaded';
    txt.textContent = `${ofdFilaments.length} filaments loaded`;
    populateBrandDropdown();
  } catch (err) {
    console.error('OFD load error:', err);
    dot.className = 'dot error';
    txt.textContent = 'OFD unavailable — use manual entry';
  }
}

function parseCSV(text) {
  const lines = text.split('\n').filter(l => l.trim());
  if (lines.length < 2) return [];
  const headers = parseCSVLine(lines[0]);
  const results = [];
  for (let i = 1; i < lines.length; i++) {
    const vals = parseCSVLine(lines[i]);
    if (vals.length < headers.length - 2) continue; // skip garbage lines
    const obj = {};
    headers.forEach((h, idx) => { obj[h] = vals[idx] || ''; });
    results.push(obj);
  }
  return results;
}

function parseCSVLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c === ',' && !inQuotes) {
      result.push(current);
      current = '';
    } else {
      current += c;
    }
  }
  result.push(current);
  return result;
}

// ─── SEARCH ───
// (replaced by cascading dropdowns)

function populateBrandDropdown() {
  const sel = document.getElementById('ofdBrandSelect');
  // Sort brands alphabetically, filter to those with filaments
  const brandsWithFilaments = ofdBrands
    .filter(b => ofdFilaments.some(f => f.brand_id === b.id))
    .sort((a, b) => a.name.localeCompare(b.name));

  sel.innerHTML = '<option value="">— Select Brand —</option>';
  brandsWithFilaments.forEach(b => {
    const count = ofdFilaments.filter(f => f.brand_id === b.id).length;
    const opt = document.createElement('option');
    opt.value = b.id;
    opt.textContent = `${b.name} (${count})`;
    sel.appendChild(opt);
  });
}

function onBrandChange() {
  const brandId = document.getElementById('ofdBrandSelect').value;
  const filSel = document.getElementById('ofdFilamentSelect');

  if (!brandId) {
    filSel.innerHTML = '<option value="">Select a brand first</option>';
    filSel.disabled = true;
    clearFilament();
    return;
  }

  // Get filaments for this brand, sorted by material then name
  const brandFilaments = ofdFilaments
    .filter(f => f.brand_id === brandId)
    .sort((a, b) => {
      if (a.material !== b.material) return a.material.localeCompare(b.material);
      return a.name.localeCompare(b.name);
    });

  filSel.innerHTML = '<option value="">— Select Filament —</option>';

  // Group by material type for cleaner display
  const grouped = {};
  brandFilaments.forEach(f => {
    const mat = f.material || 'Other';
    if (!grouped[mat]) grouped[mat] = [];
    grouped[mat].push(f);
  });

  Object.keys(grouped).sort().forEach(mat => {
    const optgroup = document.createElement('optgroup');
    optgroup.label = mat;
    grouped[mat].forEach(f => {
      const opt = document.createElement('option');
      opt.value = f.id;
      const temps = (f.min_print_temperature && f.max_print_temperature)
        ? ` — ${f.min_print_temperature}–${f.max_print_temperature}°C`
        : '';
      opt.textContent = `${f.name}${temps}`;
      optgroup.appendChild(opt);
    });
    filSel.appendChild(optgroup);
  });

  filSel.disabled = false;
  clearFilament();
}

function onFilamentChange() {
  const filId = document.getElementById('ofdFilamentSelect').value;
  if (!filId) {
    clearFilament();
    return;
  }
  const f = ofdFilaments.find(x => x.id === filId);
  if (f) selectOFDFilament(f);
}

function selectOFDFilament(f) {
  selectedFilament = {
    source: 'ofd',
    brand: f._brandName,
    name: f.name,
    material: f.material,
    density: f.density,
    diameter_tolerance: f.diameter_tolerance,
    min_print_temp: f.min_print_temperature,
    max_print_temp: f.max_print_temperature,
    min_bed_temp: f.min_bed_temperature,
    max_bed_temp: f.max_bed_temperature,
    max_dry_temp: f.max_dry_temperature,
    slicer_settings: f.slicer_settings,
  };
  showSelectedFilament();
}

function useManualFilament() {
  const brand = document.getElementById('manualBrand').value.trim();
  const name = document.getElementById('manualName').value.trim();
  const material = document.getElementById('manualMaterial').value;
  if (!brand && !name) return;
  selectedFilament = {
    source: 'manual',
    brand: brand || 'Unknown',
    name: name || material,
    material,
    min_print_temp: document.getElementById('manualTempMin').value || '',
    max_print_temp: document.getElementById('manualTempMax').value || '',
    min_bed_temp: document.getElementById('manualBedMin').value || '',
    max_bed_temp: document.getElementById('manualBedMax').value || '',
  };
  showSelectedFilament();
}

function showSelectedFilament() {
  const el = document.getElementById('selectedFilament');
  document.getElementById('sfName').textContent = `${selectedFilament.brand} ${selectedFilament.name}`;
  const temps = [];
  if (selectedFilament.min_print_temp && selectedFilament.max_print_temp) {
    temps.push(`nozzle: ${selectedFilament.min_print_temp}–${selectedFilament.max_print_temp}°C`);
  }
  if (selectedFilament.min_bed_temp && selectedFilament.max_bed_temp) {
    temps.push(`bed: ${selectedFilament.min_bed_temp}–${selectedFilament.max_bed_temp}°C`);
  }
  document.getElementById('sfDetail').textContent = `${selectedFilament.material} · ${temps.join(' · ') || 'no temp data'}`;
  el.classList.add('active');
}

function clearFilament() {
  selectedFilament = null;
  document.getElementById('selectedFilament').classList.remove('active');
}

// ─── TABS ───
function switchTab(tab) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === tab));
  document.querySelectorAll('.tab-content').forEach(c => c.classList.toggle('active', c.id === `tab-${tab}`));
}

// ─── INTENT ───
function setIntent(btn) {
  document.querySelectorAll('.intent-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  currentIntent = btn.dataset.intent;
}

// ─── FILE UPLOAD (3MF / STL) ───
async function handleFileUpload(event) {
  const file = event.target.files?.[0];
  if (!file) return;

  const zone = document.getElementById('uploadZone');
  const info = document.getElementById('modelInfo');

  zone.classList.add('has-file');
  zone.innerHTML = `<div class="upload-icon">✅</div><div class="upload-text">${file.name}</div><div class="upload-hint">${(file.size / 1024).toFixed(0)} KB — click to change</div>`;

  try {
    if (file.name.toLowerCase().endsWith('.3mf')) {
      modelData = await parse3MF(file);
    } else if (file.name.toLowerCase().endsWith('.stl')) {
      modelData = await parseSTL(file);
    }

    if (modelData) {
      info.classList.add('active');
      info.innerHTML = `
        <strong>${modelData.filename}</strong><br>
        Dimensions: ${modelData.width.toFixed(1)} × ${modelData.depth.toFixed(1)} × ${modelData.height.toFixed(1)} mm<br>
        Triangles: ${modelData.triangles.toLocaleString()}<br>
        Volume est: ~${modelData.volumeEst ? modelData.volumeEst.toFixed(1) + ' cm³' : 'N/A'}
      `;
    }
  } catch (err) {
    console.error('File parse error:', err);
    info.classList.add('active');
    info.innerHTML = `⚠️ Could not parse geometry — file will still be mentioned in settings context.`;
    modelData = { filename: file.name, error: true };
  }
}

async function parse3MF(file) {
  const JSZip = await loadJSZip();
  const zip = await JSZip.loadAsync(file);
  const modelFile = zip.file(/3D\/3dmodel\.model/i)?.[0] || zip.file(/\.model$/i)?.[0];
  if (!modelFile) throw new Error('No model file found in 3MF');

  const xml = await modelFile.async('text');
  const parser = new DOMParser();
  const doc = parser.parseFromString(xml, 'application/xml');

  // Namespace handling
  const ns = doc.documentElement.namespaceURI || '';
  const vertices = doc.querySelectorAll('vertex') || [];
  const triangles = doc.querySelectorAll('triangle') || [];

  let xs = [], ys = [], zs = [];
  vertices.forEach(v => {
    xs.push(parseFloat(v.getAttribute('x')));
    ys.push(parseFloat(v.getAttribute('y')));
    zs.push(parseFloat(v.getAttribute('z')));
  });

  const width = Math.max(...xs) - Math.min(...xs);
  const depth = Math.max(...ys) - Math.min(...ys);
  const height = Math.max(...zs) - Math.min(...zs);

  return {
    filename: file.name,
    format: '3MF',
    width, depth, height,
    triangles: triangles.length,
    vertices: vertices.length,
    volumeEst: (width * depth * height) / 1000, // rough bounding box vol in cm³
  };
}

async function parseSTL(file) {
  const buffer = await file.arrayBuffer();
  const view = new DataView(buffer);

  // Check if binary STL (80 byte header + 4 byte triangle count)
  if (buffer.byteLength > 84) {
    const triCount = view.getUint32(80, true);
    const expectedSize = 80 + 4 + triCount * 50;

    if (Math.abs(expectedSize - buffer.byteLength) < 100) {
      // Binary STL
      let xs = [], ys = [], zs = [];
      for (let i = 0; i < triCount; i++) {
        const offset = 84 + i * 50 + 12; // skip normal (12 bytes)
        for (let v = 0; v < 3; v++) {
          const voff = offset + v * 12;
          xs.push(view.getFloat32(voff, true));
          ys.push(view.getFloat32(voff + 4, true));
          zs.push(view.getFloat32(voff + 8, true));
        }
      }
      const width = Math.max(...xs) - Math.min(...xs);
      const depth = Math.max(...ys) - Math.min(...ys);
      const height = Math.max(...zs) - Math.min(...zs);
      return {
        filename: file.name,
        format: 'STL (binary)',
        width, depth, height,
        triangles: triCount,
        vertices: triCount * 3,
        volumeEst: (width * depth * height) / 1000,
      };
    }
  }

  // ASCII STL fallback
  const text = new TextDecoder().decode(buffer);
  const vertexMatches = [...text.matchAll(/vertex\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)/gi)];
  let xs = [], ys = [], zs = [];
  vertexMatches.forEach(m => {
    xs.push(parseFloat(m[1]));
    ys.push(parseFloat(m[2]));
    zs.push(parseFloat(m[3]));
  });

  const width = xs.length ? Math.max(...xs) - Math.min(...xs) : 0;
  const depth = ys.length ? Math.max(...ys) - Math.min(...ys) : 0;
  const height = zs.length ? Math.max(...zs) - Math.min(...zs) : 0;

  return {
    filename: file.name,
    format: 'STL (ASCII)',
    width, depth, height,
    triangles: Math.floor(vertexMatches.length / 3),
    vertices: vertexMatches.length,
    volumeEst: (width * depth * height) / 1000,
  };
}

let jsZipLoaded = null;
async function loadJSZip() {
  if (jsZipLoaded) return jsZipLoaded;
  return new Promise((resolve, reject) => {
    const s = document.createElement('script');
    s.src = 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js';
    s.onload = () => { jsZipLoaded = window.JSZip; resolve(window.JSZip); };
    s.onerror = reject;
    document.head.appendChild(s);
  });
}

// ─── SAVE/LOAD CONFIG ───
function loadSavedConfig() {
  const saved = localStorage.getItem('ff_config');
  if (saved) {
    try {
      const cfg = JSON.parse(saved);
      if (cfg.printer) document.getElementById('printerModel').value = cfg.printer;
      if (cfg.nozzle) document.getElementById('nozzleSize').value = cfg.nozzle;
      if (cfg.ams) document.getElementById('hasAms').value = cfg.ams;
    } catch(e) {}
  }
}

function saveConfig() {
  const cfg = {
    printer: document.getElementById('printerModel').value,
    nozzle: document.getElementById('nozzleSize').value,
    ams: document.getElementById('hasAms').value,
  };
  localStorage.setItem('ff_config', JSON.stringify(cfg));
}

// Save config on change
['printerModel', 'nozzleSize', 'hasAms'].forEach(id => {
  document.getElementById(id).addEventListener('change', saveConfig);
});

// ─── GENERATE SETTINGS ───
async function generateSettings() {
  if (!selectedFilament) {
    alert('Please select a filament first.');
    return;
  }

  const btn = document.getElementById('btnGenerate');
  btn.innerHTML = '<span class="spinner"></span> Generating...';
  btn.classList.add('loading');
  btn.disabled = true;

  const printer = document.getElementById('printerModel').value;
  const nozzle = document.getElementById('nozzleSize').value;
  const ams = document.getElementById('hasAms').value;
  const printerSpec = PRINTER_SPECS[printer];

  // Build prompt
  let filamentCtx = `Brand: ${selectedFilament.brand}
Filament: ${selectedFilament.name}
Material: ${selectedFilament.material}`;

  if (selectedFilament.min_print_temp) filamentCtx += `\nManufacturer nozzle temp range: ${selectedFilament.min_print_temp}–${selectedFilament.max_print_temp}°C`;
  if (selectedFilament.min_bed_temp) filamentCtx += `\nManufacturer bed temp range: ${selectedFilament.min_bed_temp}–${selectedFilament.max_bed_temp}°C`;
  if (selectedFilament.density) filamentCtx += `\nDensity: ${selectedFilament.density} g/cm³`;
  if (selectedFilament.source === 'ofd') filamentCtx += `\nSource: Open Filament Database (verified community data)`;

  let modelCtx = '';
  if (modelData && !modelData.error) {
    modelCtx = `\n\nModel Information:
Filename: ${modelData.filename}
Format: ${modelData.format}
Dimensions: ${modelData.width.toFixed(1)} × ${modelData.depth.toFixed(1)} × ${modelData.height.toFixed(1)} mm
Triangle count: ${modelData.triangles.toLocaleString()}
Bounding box volume: ~${modelData.volumeEst?.toFixed(1) || 'unknown'} cm³`;
  }

  const systemPrompt = `You are an expert 3D printing settings engine. You provide optimized slicer settings for Bambu Studio.

RESPOND ONLY WITH A JSON OBJECT. No markdown, no backticks, no explanation outside the JSON.

The JSON must have this exact structure:
{
  "temperature": {
    "nozzle": "NUMBER°C",
    "nozzle_first_layer": "NUMBER°C",
    "bed": "NUMBER°C",
    "bed_first_layer": "NUMBER°C"
  },
  "speed": {
    "outer_wall": "NUMBERmm/s",
    "inner_wall": "NUMBERmm/s",
    "infill": "NUMBERmm/s",
    "top_surface": "NUMBERmm/s",
    "travel": "NUMBERmm/s",
    "first_layer": "NUMBERmm/s"
  },
  "layers": {
    "layer_height": "NUMBERmm",
    "first_layer_height": "NUMBERmm",
    "walls": "NUMBER",
    "top_layers": "NUMBER",
    "bottom_layers": "NUMBER"
  },
  "infill": {
    "density": "NUMBER%",
    "pattern": "PATTERN_NAME"
  },
  "cooling": {
    "fan_speed": "NUMBER%",
    "fan_first_layers": "NUMBER layers off",
    "min_layer_time": "NUMBERs",
    "aux_fan": "on/off"
  },
  "support": {
    "enabled": "yes/no/depends on model",
    "type": "TYPE or N/A",
    "threshold": "NUMBER° or N/A"
  },
  "adhesion": {
    "brim": "yes/no/recommended",
    "brim_width": "NUMBERmm or N/A"
  },
  "advanced": {
    "pressure_advance": "NUMBER",
    "retraction_length": "NUMBERmm",
    "retraction_speed": "NUMBERmm/s",
    "z_hop": "NUMBERmm or off"
  },
  "bambu_studio_profile": "PROFILE_NAME to start from",
  "notes": ["array", "of", "important", "tips", "and", "warnings"],
  "model_specific_notes": ["array", "of", "notes", "about", "the", "uploaded", "model"]
}

Important rules:
- All values should be specific numbers, not ranges
- Optimize for the stated print intent
- Consider the printer's capabilities and limitations
- Factor in model geometry if provided
- Include practical tips in notes`;

  const userPrompt = `Generate optimized Bambu Studio slicer settings for:

Printer: ${printerSpec.name}
Nozzle: ${nozzle}mm
AMS: ${ams}
Max volumetric flow: ${printerSpec.maxVolFlow} mm³/s
Has enclosed chamber: ${printerSpec.hasChamber}
Bed surface: ${printerSpec.bedType}

Filament:
${filamentCtx}

Print Intent: ${currentIntent.toUpperCase()}
${currentIntent === 'quality' ? '(Prioritize surface finish, accuracy, minimal artifacts)' : ''}
${currentIntent === 'balanced' ? '(Good balance of quality and speed)' : ''}
${currentIntent === 'speed' ? '(Maximize speed while maintaining structural integrity)' : ''}
${currentIntent === 'prototype' ? '(Fastest possible, minimal material, just needs to hold shape)' : ''}
${modelCtx}`;

  try {
    const data = await claudeRequest({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 2000,
      system: systemPrompt,
      messages: [{ role: 'user', content: userPrompt }],
    });

    const text = data.content.map(c => c.text || '').join('');
    const cleaned = text.replace(/```json|```/g, '').trim();

    document.getElementById('rawResponse').textContent = cleaned;

    const settings = JSON.parse(cleaned);
    renderSettings(settings);

    // Save to history and track for preset saving
    const printerSpec = PRINTER_SPECS[printer];
    const histEntry = addToHistory(selectedFilament, printerSpec.name, nozzle, currentIntent, settings, cleaned);
    lastGeneratedResult = histEntry;

  } catch (err) {
    console.error('Generate error:', err);
    alert(`Error: ${err.message}`);
  } finally {
    btn.innerHTML = 'Generate Settings';
    btn.classList.remove('loading');
    btn.disabled = false;
  }
}

// ─── RENDER SETTINGS ───
function renderSettings(s) {
  document.getElementById('emptyState').style.display = 'none';
  const output = document.getElementById('settingsOutput');
  output.classList.add('active');

  // Title
  document.getElementById('outputTitle').textContent = `${selectedFilament.brand} ${selectedFilament.name} — Settings`;
  const printerSpec = PRINTER_SPECS[document.getElementById('printerModel').value];
  document.getElementById('outputMeta').textContent = `${printerSpec.name} · ${document.getElementById('nozzleSize').value}mm nozzle · ${currentIntent} mode`;

  // Specs bar
  const specsBar = document.getElementById('specsBar');
  specsBar.innerHTML = '';
  const chips = [
    { label: 'Material', val: selectedFilament.material },
    { label: 'Nozzle', val: s.temperature?.nozzle || '?' },
    { label: 'Bed', val: s.temperature?.bed || '?' },
    { label: 'Layer', val: s.layers?.layer_height || '?' },
    { label: 'Infill', val: s.infill?.density || '?' },
    { label: 'Profile', val: s.bambu_studio_profile || 'Generic' },
  ];
  chips.forEach(c => {
    specsBar.innerHTML += `<div class="spec-chip"><span class="spec-label">${c.label}</span><span class="spec-val">${c.val}</span></div>`;
  });

  // Settings grid
  const grid = document.getElementById('settingsGrid');
  grid.innerHTML = '';

  const sections = [
    { icon: '🌡️', title: 'Temperature', data: s.temperature },
    { icon: '⚡', title: 'Speed', data: s.speed },
    { icon: '📏', title: 'Layers & Walls', data: s.layers },
    { icon: '🔲', title: 'Infill', data: s.infill },
    { icon: '❄️', title: 'Cooling', data: s.cooling },
    { icon: '🏗️', title: 'Support', data: s.support },
    { icon: '📎', title: 'Adhesion', data: s.adhesion },
    { icon: '🔧', title: 'Advanced', data: s.advanced },
  ];

  sections.forEach(sec => {
    if (!sec.data) return;
    const card = document.createElement('div');
    card.className = 'setting-card';
    let rows = '';
    Object.entries(sec.data).forEach(([key, val]) => {
      const label = key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
      rows += `<div class="setting-row"><span class="setting-label">${label}</span><span class="setting-value">${val}</span></div>`;
    });
    card.innerHTML = `<div class="setting-card-header"><span class="setting-card-icon">${sec.icon}</span>${sec.title}</div>${rows}`;
    grid.appendChild(card);
  });

  // Notes
  const notesCard = document.getElementById('notesCard');
  const allNotes = [...(s.notes || []), ...(s.model_specific_notes || [])];
  if (allNotes.length > 0) {
    notesCard.style.display = 'block';
    notesCard.innerHTML = `<h3>💡 Notes & Tips</h3><ul>${allNotes.map(n => `<li>${n}</li>`).join('')}</ul>`;
  } else {
    notesCard.style.display = 'none';
  }

  // Scroll to top of output
  document.querySelector('.main-content').scrollTop = 0;
}

// ─── COPY SETTINGS ───
function copySettings() {
  const text = buildSettingsText();
  const btns = document.querySelectorAll('#settingsOutput .output-header .btn-sm');
  const copyBtn = [...btns].find(b => b.textContent.includes('Copy'));
  copyWithFeedback(text, copyBtn);
}

function toggleRaw() {
  document.getElementById('rawResponse').classList.toggle('active');
}

// ─── MAIN TABS ───
function switchMainTab(tab) {
  document.querySelectorAll('.main-tab').forEach(b => b.classList.toggle('active', b.dataset.mtab === tab));
  document.querySelectorAll('.main-tab-content').forEach(c => c.classList.toggle('active', c.id === `mtab-${tab}`));
}

// ─── HISTORY SYSTEM ───
let history = JSON.parse(localStorage.getItem('ff_history') || '[]');
let presets = JSON.parse(localStorage.getItem('ff_presets') || '[]');
let customFilaments = JSON.parse(localStorage.getItem('ff_custom_filaments') || '[]');
let lastGeneratedResult = null;

function addToHistory(filament, printer, nozzle, intent, settings, rawJSON) {
  const entry = {
    id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
    timestamp: new Date().toISOString(),
    filament: { brand: filament.brand, name: filament.name, material: filament.material },
    printer,
    nozzle,
    intent,
    settings,
    rawJSON,
  };
  history.unshift(entry);
  if (history.length > 50) history = history.slice(0, 50); // cap at 50
  localStorage.setItem('ff_history', JSON.stringify(history));
  renderHistory();
  updateHistoryCount();
  return entry;
}

function savePreset() {
  if (!lastGeneratedResult) return;
  const name = prompt('Name this preset:', `${lastGeneratedResult.filament.brand} ${lastGeneratedResult.filament.name} — ${lastGeneratedResult.intent}`);
  if (!name) return;

  const preset = { ...lastGeneratedResult, presetName: name, savedAt: new Date().toISOString() };
  presets.unshift(preset);
  localStorage.setItem('ff_presets', JSON.stringify(presets));
  renderPresets();

  const btn = document.getElementById('btnSavePreset');
  btn.textContent = '✅ Saved!';
  setTimeout(() => { btn.textContent = '⭐ Save'; }, 1500);
}

function renderHistory() {
  const list = document.getElementById('historyList');
  if (history.length === 0) {
    list.innerHTML = '<div class="empty-history">No history yet. Generate some settings to see them here.</div>';
    return;
  }

  list.innerHTML = '';
  history.forEach((entry, idx) => {
    const item = document.createElement('div');
    item.className = 'history-item';
    const date = new Date(entry.timestamp);
    const timeStr = date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    item.innerHTML = `
      <div class="hi-info" onclick="loadHistoryEntry(${idx})">
        <div class="hi-title">${entry.filament.brand} ${entry.filament.name}</div>
        <div class="hi-meta">${entry.printer} · ${entry.nozzle}mm · ${entry.intent} · ${timeStr}</div>
      </div>
      <div class="hi-actions">
        <button class="hi-action-btn" onclick="loadHistoryEntry(${idx})">Load</button>
        <button class="hi-action-btn delete" onclick="deleteHistoryEntry(${idx})">✕</button>
      </div>
    `;
    list.appendChild(item);
  });
}

function renderPresets() {
  const list = document.getElementById('presetsList');
  if (presets.length === 0) {
    list.innerHTML = '<div class="empty-history">No saved presets yet. Generate settings and click ⭐ Save.</div>';
    return;
  }

  list.innerHTML = '';
  presets.forEach((entry, idx) => {
    const item = document.createElement('div');
    item.className = 'history-item';
    item.innerHTML = `
      <div class="hi-info" onclick="loadPreset(${idx})">
        <div class="hi-title">${entry.presetName}<span class="saved-badge">preset</span></div>
        <div class="hi-meta">${entry.filament.brand} ${entry.filament.name} · ${entry.printer} · ${entry.nozzle}mm · ${entry.intent}</div>
      </div>
      <div class="hi-actions">
        <button class="hi-action-btn" onclick="loadPreset(${idx})">Load</button>
        <button class="hi-action-btn delete" onclick="deletePreset(${idx})">✕</button>
      </div>
    `;
    list.appendChild(item);
  });
}

function loadHistoryEntry(idx) {
  const entry = history[idx];
  if (!entry) return;
  displaySavedResult(entry);
}

function loadPreset(idx) {
  const entry = presets[idx];
  if (!entry) return;
  displaySavedResult(entry);
}

function displaySavedResult(entry) {
  switchMainTab('results');
  lastGeneratedResult = entry;

  selectedFilament = {
    source: 'history',
    brand: entry.filament.brand,
    name: entry.filament.name,
    material: entry.filament.material,
  };
  showSelectedFilament();

  const settings = entry.settings;
  document.getElementById('rawResponse').textContent = entry.rawJSON || JSON.stringify(settings, null, 2);
  renderSettings(settings);
}

function deleteHistoryEntry(idx) {
  history.splice(idx, 1);
  localStorage.setItem('ff_history', JSON.stringify(history));
  renderHistory();
  updateHistoryCount();
}

function deletePreset(idx) {
  presets.splice(idx, 1);
  localStorage.setItem('ff_presets', JSON.stringify(presets));
  renderPresets();
}

function clearAllHistory() {
  if (!confirm('Clear all history?')) return;
  history = [];
  localStorage.setItem('ff_history', JSON.stringify(history));
  renderHistory();
  updateHistoryCount();
}

function clearAllPresets() {
  if (!confirm('Clear all saved presets?')) return;
  presets = [];
  localStorage.setItem('ff_presets', JSON.stringify(presets));
  renderPresets();
}

function updateHistoryCount() {
  const el = document.getElementById('historyCount');
  const total = history.length + presets.length;
  el.textContent = total > 0 ? `(${total})` : '';
}

// ─── CUSTOM FILAMENTS ───
function saveCustomFilament() {
  const brand = document.getElementById('manualBrand').value.trim();
  const name = document.getElementById('manualName').value.trim();
  const material = document.getElementById('manualMaterial').value;
  if (!brand || !name) {
    alert('Please enter at least a brand and filament name.');
    return;
  }

  const custom = {
    id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
    source: 'custom',
    brand,
    name,
    material,
    min_print_temp: document.getElementById('manualTempMin').value || '',
    max_print_temp: document.getElementById('manualTempMax').value || '',
    min_bed_temp: document.getElementById('manualBedMin').value || '',
    max_bed_temp: document.getElementById('manualBedMax').value || '',
  };

  // Check for duplicates
  const exists = customFilaments.find(f => f.brand === brand && f.name === name);
  if (exists) {
    if (!confirm(`"${brand} ${name}" already exists. Replace it?`)) return;
    customFilaments = customFilaments.filter(f => f.id !== exists.id);
  }

  customFilaments.push(custom);
  localStorage.setItem('ff_custom_filaments', JSON.stringify(customFilaments));
  renderCustomFilaments();

  // Clear the manual form
  document.getElementById('manualBrand').value = '';
  document.getElementById('manualName').value = '';
  document.getElementById('manualTempMin').value = '';
  document.getElementById('manualTempMax').value = '';
  document.getElementById('manualBedMin').value = '';
  document.getElementById('manualBedMax').value = '';
}

function renderCustomFilaments() {
  // Render in the My Filaments tab
  const selectList = document.getElementById('customFilamentSelectList');
  const noCustom = document.getElementById('noCustomFilaments');

  if (customFilaments.length === 0) {
    selectList.innerHTML = '';
    noCustom.style.display = 'block';
    return;
  }

  noCustom.style.display = 'none';
  selectList.innerHTML = '';

  customFilaments.forEach((f, idx) => {
    const item = document.createElement('div');
    item.className = 'history-item';
    const temps = [];
    if (f.min_print_temp && f.max_print_temp) temps.push(`${f.min_print_temp}–${f.max_print_temp}°C nozzle`);
    if (f.min_bed_temp && f.max_bed_temp) temps.push(`${f.min_bed_temp}–${f.max_bed_temp}°C bed`);
    item.innerHTML = `
      <div class="hi-info" onclick="useCustomFilament(${idx})">
        <div class="hi-title">${f.brand} ${f.name} <span class="material-tag ${['PLA','PETG','ABS','TPU'].includes(f.material) ? f.material : 'other'}" style="font-size:9px;vertical-align:middle">${f.material}</span></div>
        <div class="hi-meta">${temps.join(' · ') || 'no temp data'}</div>
      </div>
      <div class="hi-actions">
        <button class="hi-action-btn" onclick="useCustomFilament(${idx})">Use</button>
        <button class="hi-action-btn delete" onclick="deleteCustomFilament(${idx})">✕</button>
      </div>
    `;
    selectList.appendChild(item);
  });

  // Also render in the manual tab's list
  const manualList = document.getElementById('customFilamentsList');
  if (customFilaments.length > 0) {
    manualList.innerHTML = `<div style="font-size:11px;color:var(--text-muted);margin-top:4px;margin-bottom:4px">💾 Saved filaments (${customFilaments.length})</div>`;
    customFilaments.forEach((f, idx) => {
      const chip = document.createElement('div');
      chip.className = 'custom-fil-item';
      chip.innerHTML = `
        <div>
          <span class="cfi-name">${f.brand} ${f.name}</span>
          <span class="cfi-mat">${f.material}</span>
        </div>
        <button class="custom-fil-delete" onclick="deleteCustomFilament(${idx})">✕</button>
      `;
      chip.style.cursor = 'pointer';
      chip.querySelector('.cfi-name').addEventListener('click', () => useCustomFilament(idx));
      manualList.appendChild(chip);
    });
  } else {
    manualList.innerHTML = '';
  }
}

function useCustomFilament(idx) {
  const f = customFilaments[idx];
  if (!f) return;
  selectedFilament = { ...f, source: 'custom' };
  showSelectedFilament();
}

function deleteCustomFilament(idx) {
  customFilaments.splice(idx, 1);
  localStorage.setItem('ff_custom_filaments', JSON.stringify(customFilaments));
  renderCustomFilaments();
}

// ─── INIT HISTORY/PRESETS/CUSTOM ON LOAD ───
document.addEventListener('DOMContentLoaded', () => {
  renderHistory();
  renderPresets();
  renderCustomFilaments();
  updateHistoryCount();
  checkOnboarding();
});

// ─── ONBOARDING ───
function checkOnboarding() {
  const seen = localStorage.getItem('ff_onboarding_done');
  if (!seen) {
    document.getElementById('onboardingModal').classList.add('active');
  }
}

function closeOnboarding() {
  localStorage.setItem('ff_onboarding_done', 'true');
  closeModal('onboardingModal');
}

// ─── SIDEBAR TOGGLE (MOBILE) ───
function toggleSidebar() {
  const content = document.getElementById('sidebarContent');
  const btn = document.getElementById('sidebarToggle');
  const expanded = content.classList.toggle('expanded');
  btn.textContent = expanded ? '▼ Configure Settings' : '▶ Configure Settings';
}

// ─── EXPORT ───
function exportSettings() {
  const text = buildSettingsText();
  document.getElementById('exportText').value = text;
  openModal('exportModal');
}

function closeExportModal() {
  closeModal('exportModal');
}

function copyExport() {
  const textarea = document.getElementById('exportText');
  textarea.select();
  const btn = document.querySelector('#exportModal .btn-primary');
  copyWithFeedback(textarea.value, btn, '✅ Copied!');
}

function buildSettingsText() {
  let text = '═══════════════════════════════════════\n';
  text += '  FILAMENTFORGE — PRINT SETTINGS\n';
  text += '═══════════════════════════════════════\n\n';

  text += document.getElementById('outputTitle').textContent + '\n';
  text += document.getElementById('outputMeta').textContent + '\n\n';

  // Specs line
  const chips = document.querySelectorAll('#specsBar .spec-chip');
  if (chips.length) {
    chips.forEach(c => {
      const label = c.querySelector('.spec-label').textContent;
      const val = c.querySelector('.spec-val').textContent;
      text += `${label}: ${val}  `;
    });
    text += '\n\n';
  }

  text += '───────────────────────────────────────\n';

  const grid = document.getElementById('settingsGrid');
  grid.querySelectorAll('.setting-card').forEach(card => {
    const title = card.querySelector('.setting-card-header').textContent.trim();
    text += `\n${title}\n`;
    card.querySelectorAll('.setting-row').forEach(row => {
      const label = row.querySelector('.setting-label').textContent;
      const val = row.querySelector('.setting-value').textContent;
      text += `  ${label.padEnd(24)} ${val}\n`;
    });
  });

  const notes = document.getElementById('notesCard');
  if (notes.style.display !== 'none') {
    text += '\n───────────────────────────────────────\n';
    text += '\nNotes & Tips\n';
    notes.querySelectorAll('li').forEach(li => {
      text += `  • ${li.textContent}\n`;
    });
  }

  text += '\n═══════════════════════════════════════\n';
  text += '  Generated by FilamentForge\n';
  text += '  Filament data: Open Filament Database\n';
  text += '  AI: Claude by Anthropic\n';
  text += '═══════════════════════════════════════\n';

  return text;
}
