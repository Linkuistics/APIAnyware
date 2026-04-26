// ui/chooser.js — Chooser panel JavaScript
//
// Handles: search input debouncing, keyboard navigation (up/down/enter/escape/tab),
// result rendering via updateResults(), and postMessage communication with Racket.
//
// Messages sent to Racket (via window.webkit.messageHandlers.modaliser.postMessage):
//   { type: "ready" }                         — page loaded, request initial results
//   { type: "search", query: "..." }          — debounced search input
//   { type: "select", originalIndex: N }      — Enter pressed (primary action)
//   { type: "secondary-action", originalIndex: N } — Cmd+Enter (secondary action)
//   { type: "cancel" }                        — Escape pressed
//   { type: "toggle-actions" }                — Tab pressed (show/hide action panel)

var chooserItems = [];
var chooserSelectedIndex = 0;
var chooserResultsMaxHeight = 0;

document.addEventListener('DOMContentLoaded', function() {
  var input = document.getElementById('chooser-input');
  if (!input) return;

  input.focus();
  input.setSelectionRange(input.value.length, input.value.length);

  // Signal to Racket that the page is ready for content
  window.webkit.messageHandlers.modaliser.postMessage({ type: 'ready' });

  // Debounce search input (100ms)
  var debounceTimer = null;
  input.addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(function() {
      window.webkit.messageHandlers.modaliser.postMessage({
        type: 'search',
        query: input.value
      });
    }, 100);
  });

  // Keyboard navigation — handled entirely in JS
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      moveSelection(1);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      moveSelection(-1);
    } else if (e.key === 'Enter' && e.metaKey) {
      e.preventDefault();
      sendSelect('secondary-action');
    } else if (e.key === 'Enter') {
      e.preventDefault();
      sendSelect('select');
    } else if (e.key === 'Escape') {
      e.preventDefault();
      window.webkit.messageHandlers.modaliser.postMessage({ type: 'cancel' });
    } else if (e.key === 'Tab') {
      e.preventDefault();
      window.webkit.messageHandlers.modaliser.postMessage({ type: 'toggle-actions' });
    }
  });
});

function moveSelection(delta) {
  if (chooserItems.length === 0) return;
  var rows = document.querySelectorAll('.chooser-row');
  var oldIndex = chooserSelectedIndex;
  chooserSelectedIndex = Math.max(0, Math.min(chooserItems.length - 1, chooserSelectedIndex + delta));
  if (oldIndex !== chooserSelectedIndex) {
    if (oldIndex < rows.length) rows[oldIndex].classList.remove('selected');
    if (chooserSelectedIndex < rows.length) {
      rows[chooserSelectedIndex].classList.add('selected');
      rows[chooserSelectedIndex].scrollIntoView({ block: 'nearest' });
    }
  }
}

function sendSelect(type) {
  if (chooserItems.length === 0) return;
  var item = chooserItems[chooserSelectedIndex];
  if (!item) return;
  window.webkit.messageHandlers.modaliser.postMessage({
    type: type,
    originalIndex: item.x
  });
}

// Called from Racket with fuzzy match results as JSON.
// Renders results directly into the DOM — no round-trip through Racket.
// item: {d: displayText, s: searchText, p: path, k: kind, i: [matchedIndices], x: origIndex}
function updateResults(items, totalCount) {
  chooserItems = items;
  chooserSelectedIndex = 0;

  var ul = document.querySelector('.chooser-results');
  if (!ul) return;

  var html = '';
  var len = items.length;
  for (var n = 0; n < len; n++) {
    var item = items[n];
    var isDir = item.k === 'directory';
    var cls = n === 0 ? 'chooser-row selected' : 'chooser-row';

    html += '<li class="' + cls + '">';

    if (item.p) {
      var textCls = isDir ? 'chooser-row-text chooser-dir' : 'chooser-row-text';
      html += '<div class="chooser-row-content">';
      html += '<span class="' + textCls + '">';
      html += isDir ? highlightText(item.d, item.i) : escapeHtml(item.d);
      html += '</span>';
      html += '<div class="chooser-row-subtext">';
      html += isDir ? escapeHtml(item.p) : highlightText(item.s, item.i);
      html += '</div></div>';
    } else {
      html += '<span class="chooser-row-text">';
      html += highlightText(item.s, item.i);
      html += '</span>';
    }

    html += '</li>';
  }

  ul.innerHTML = html;

  // High-water mark — only grow, never shrink (capped at max-height)
  var currentHeight = ul.scrollHeight;
  if (currentHeight > chooserResultsMaxHeight) {
    chooserResultsMaxHeight = Math.min(currentHeight, 280);
  }
  ul.style.minHeight = chooserResultsMaxHeight + 'px';

  var footer = document.querySelector('.chooser-footer');
  if (footer) {
    footer.textContent = totalCount + (totalCount === 1 ? ' item' : ' items');
  }
}

function escapeHtml(str) {
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function highlightText(text, indices) {
  if (!indices || indices.length === 0) return escapeHtml(text);
  var set = new Set(indices);
  var result = '';
  for (var i = 0; i < text.length; i++) {
    var c = escapeHtml(text[i]);
    result += set.has(i) ? '<span class="match">' + c + '</span>' : c;
  }
  return result;
}
