// App logic goes here.
//
// Available shared helpers (loaded before this file):
//   shared/js/ui.js  — openModal(id), closeModal(id), escHtml(str), copyWithFeedback(text, btn)
//   shared/js/api.js — claudeRequest({ model, max_tokens, system, messages })
//
// Example Claude call through the server-side proxy:
//   const data = await claudeRequest({
//     model: 'claude-haiku-4-5-20251001',
//     max_tokens: 1000,
//     messages: [{ role: 'user', content: 'Hello!' }],
//   });
//   console.log(data.content[0].text);

console.log('New app loaded.');
