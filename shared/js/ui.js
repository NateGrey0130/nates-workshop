// Shared UI helpers for all workshop apps

function openModal(id) {
  document.getElementById(id).classList.add('active');
}

function closeModal(id) {
  document.getElementById(id).classList.remove('active');
}

function escHtml(str) {
  const d = document.createElement('div');
  d.textContent = str;
  return d.innerHTML;
}

function copyWithFeedback(text, btn, doneLabel = '✅ Copied!', delay = 1500) {
  return navigator.clipboard.writeText(text).then(() => {
    if (!btn) return;
    const orig = btn.textContent;
    btn.textContent = doneLabel;
    setTimeout(() => { btn.textContent = orig; }, delay);
  });
}
