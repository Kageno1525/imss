class WebScripts {
  WebScripts._();

  // ═══════ Login ═══════
  static const fillLogin = r'''
(function(){
  try {
    var U = "shahd0";
    var P = "Sh235qs216!";
    var root = document.querySelector('#app') || document;
    var u = root.querySelector('input[type=text]') || root.querySelector('input[type=email]');
    var p = root.querySelector('input[type=password]');
    var b = root.querySelector('button[type=submit]') || root.querySelector('form button');
    if (!u || !p || !b) return 'not-ready';
    var setter = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(u), 'value').set
              || Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    function fire(el, val){
      el.focus();
      try { setter.call(el, val); } catch(e){ el.value = val; }
      ['input','change','keyup','blur'].forEach(function(ev){
        el.dispatchEvent(new Event(ev, {bubbles:true}));
      });
    }
    fire(u, U);
    fire(p, P);
    setTimeout(function(){
      try { b.click(); } catch(e){}
    }, 150);
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const diag = r'''
(function(){
  try {
    var url = location.href;
    var inputs = document.querySelectorAll('input').length;
    var buttons = document.querySelectorAll('button').length;
    var hasPwd = !!document.querySelector('input[type=password]');
    var hasTable = !!document.querySelector('table');
    return [url, inputs, buttons, hasPwd ? 1 : 0, hasTable ? 1 : 0].join('|');
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Ranges ═══════
  static const openRanges = r'''
(function(){
  try {
    var btn = document.querySelector('button.ss-trigger.input[aria-haspopup="listbox"]');
    if (!btn) {
      var bs = document.querySelectorAll('button.ss-trigger');
      if (bs.length > 0) btn = bs[0];
    }
    if (!btn) return 'no-btn';
    btn.click();
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const isRangeDropdownOpen = r'''
(function(){ return document.querySelector('.ss-pop') ? 'yes' : 'no'; })()
''';

  static const readRanges = r'''
(function(){
  try {
    var items = document.querySelectorAll('.ss-pop .ss-item, .ss-list .ss-item');
    var arr = [];
    items.forEach(function(li){
      if (li.querySelector('.ss-clear')){ arr.push('All ranges'); return; }
      var s = li.querySelector('span');
      var t = s ? (s.innerText || s.textContent || '').trim() : '';
      if (t) arr.push(t);
    });
    return JSON.stringify(arr);
  } catch(e){ return 'err:' + e.message; }
})()
''';

  /// بحث داخل قائمة الرنجات (يستخدم searchInput = %QUERY%)
  static const searchRanges = r'''
(function(){
  try {
    var q = %QUERY%;
    var inp = document.querySelector('.ss-pop input.input[role="combobox"], .ss-pop input.input');
    if (!inp) {
      var all = document.querySelectorAll('input[role="combobox"]');
      if (all.length > 0) inp = all[0];
    }
    if (!inp) return 'no-input';
    var setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    inp.focus();
    try { setter.call(inp, q); } catch(e){ inp.value = q; }
    inp.dispatchEvent(new Event('input', {bubbles:true}));
    inp.dispatchEvent(new Event('change', {bubbles:true}));
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  /// اختيار رنج بالاسم
  static const selectRange = r'''
(function(){
  try {
    var name = %NAME%;
    var items = document.querySelectorAll('.ss-item');
    for (var i=0;i<items.length;i++){
      var isAll = !!items[i].querySelector('.ss-clear');
      var s = items[i].querySelector('span');
      var t = isAll ? 'All ranges' : (s ? (s.innerText||'').trim() : '');
      if (t !== name) continue;
      var el = items[i];
      var r = el.getBoundingClientRect();
      var cx = r.left + r.width/2;
      var cy = r.top + r.height/2;
      var dn = {bubbles:true, cancelable:true, view:window, clientX:cx, clientY:cy, button:0, buttons:1};
      var up = {bubbles:true, cancelable:true, view:window, clientX:cx, clientY:cy, button:0, buttons:0};
      try { el.dispatchEvent(new PointerEvent('pointerdown', dn)); } catch(e){}
      try { el.dispatchEvent(new MouseEvent('mousedown', dn)); } catch(e){}
      try { el.dispatchEvent(new PointerEvent('pointerup', up)); } catch(e){}
      try { el.dispatchEvent(new MouseEvent('mouseup', up)); } catch(e){}
      try { el.dispatchEvent(new MouseEvent('click', up)); } catch(e){}
      return 'ok';
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const readSelectedRange = r'''
(function(){
  try {
    var btn = document.querySelector('button.ss-trigger.input[aria-haspopup="listbox"]');
    if (!btn) return '';
    var sp = btn.querySelector('.ss-placeholder, span');
    return sp ? (sp.innerText||sp.textContent||'').trim() : (btn.innerText||'').trim();
  } catch(e){ return ''; }
})()
''';

  // ═══════ Filter ═══════
  static const clickFilter = r'''
(function(){
  try {
    var f = document.querySelector('button.btn.btn-danger');
    if (!f){
      var btns = document.querySelectorAll('button');
      for (var i=0;i<btns.length;i++){
        var t = (btns[i].innerText||'').trim().toLowerCase();
        if (t === 'filter'){ f = btns[i]; break; }
      }
    }
    if (!f) return 'no-filter';
    f.click();
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Page size = 5000 ═══════
  static const setPageSize5000 = r'''
(function(){
  try {
    var sels = document.querySelectorAll('select.select, select');
    for (var i=0;i<sels.length;i++){
      var s = sels[i];
      var has5000 = false;
      for (var j=0;j<s.options.length;j++){
        if (String(s.options[j].value) === '5000'){ has5000 = true; break; }
      }
      if (has5000){
        var setter = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set;
        try { setter.call(s, '5000'); } catch(e){ s.value = '5000'; }
        for (var k=0;k<s.options.length;k++){
          s.options[k].selected = (String(s.options[k].value) === '5000');
        }
        s.dispatchEvent(new Event('input', {bubbles:true}));
        s.dispatchEvent(new Event('change', {bubbles:true}));
        return 'ok';
      }
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Stats ═══════
  /// يرجع JSON فيه: total, available, added, rowsOnPage
  static const readStats = r'''
(function(){
  try {
    // total من "Showing X to Y of N entries"
    var total = 0;
    var pg = document.querySelector('.pg-left');
    if (pg){
      var m = (pg.innerText||pg.textContent||'').match(/of\s+([\d,]+)/i);
      if (m) total = parseInt(m[1].replace(/,/g,''), 10) || 0;
    }

    // فهرس عمود Client
    var clientIdx = -1;
    var ths = document.querySelectorAll('table th');
    for (var i=0;i<ths.length;i++){
      var t = (ths[i].innerText||ths[i].textContent||'').trim();
      if (t.indexOf('Client') >= 0){ clientIdx = i; break; }
    }

    var rows = document.querySelectorAll('tr.vrow');
    var available = 0, added = 0;
    for (var r=0;r<rows.length;r++){
      var tds = rows[r].querySelectorAll('td');
      if (clientIdx < 0 || clientIdx >= tds.length) continue;
      var v = (tds[clientIdx].innerText || tds[clientIdx].textContent || '').trim();
      if (v === '-' || v === '' || v === '—') available++;
      else added++;
    }

    return JSON.stringify({
      total: total,
      available: available,
      added: added,
      rowsOnPage: rows.length
    });
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Check Available Checkboxes ═══════
  /// يختار N رقم متاح (Client = -) ويضغط الـ checkbox
  static const checkAvailable = r'''
(function(){
  try {
    var n = %COUNT%;
    var clientIdx = -1;
    var ths = document.querySelectorAll('table th');
    for (var i=0;i<ths.length;i++){
      var t = (ths[i].innerText||ths[i].textContent||'').trim();
      if (t.indexOf('Client') >= 0){ clientIdx = i; break; }
    }
    if (clientIdx < 0) return 'no-column';

    var rows = document.querySelectorAll('tr.vrow');
    var checked = 0;
    for (var r=0;r<rows.length && checked < n;r++){
      var row = rows[r];
      var tds = row.querySelectorAll('td');
      if (clientIdx >= tds.length) continue;
      var v = (tds[clientIdx].innerText || tds[clientIdx].textContent || '').trim();
      if (v === '-' || v === '' || v === '—'){
        var cb = row.querySelector('input.checkbox');
        if (cb && !cb.checked){
          cb.click();
          checked++;
        }
      }
    }
    return 'ok|checked=' + checked;
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Click Add Button ═══════
  static const clickAddButton = r'''
(function(){
  try {
    var b = document.querySelector('.head-actions button.btn.btn-primary');
    if (b){ b.click(); return 'ok'; }
    // fallback: زر فيه كلمة Add أو إضافة
    var all = document.querySelectorAll('button.btn.btn-primary');
    for (var i=0;i<all.length;i++){
      var t = (all[i].innerText||'').trim().toLowerCase();
      if (t.indexOf('add') >= 0 || t.indexOf('إضافة') >= 0 || t.indexOf('اضف') >= 0){
        all[i].click();
        return 'ok';
      }
    }
    return 'no-btn';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: DLR = 7/1 ═══════
  static const selectDlr7_1 = r'''
(function(){
  try {
    var sels = document.querySelectorAll('.modal-body select.select, select.select, select');
    for (var i=0;i<sels.length;i++){
      var s = sels[i];
      var hasOpt = false;
      for (var j=0;j<s.options.length;j++){
        if (String(s.options[j].value) === '7-1'){ hasOpt = true; break; }
      }
      if (hasOpt){
        var setter = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set;
        try { setter.call(s, '7-1'); } catch(e){ s.value = '7-1'; }
        for (var k=0;k<s.options.length;k++){
          s.options[k].selected = (String(s.options[k].value) === '7-1');
        }
        s.dispatchEvent(new Event('input', {bubbles:true}));
        s.dispatchEvent(new Event('change', {bubbles:true}));
        return 'ok';
      }
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: Open user dropdown ═══════
  static const openUserDropdown = r'''
(function(){
  try {
    // الزر بتاع User في الـ modal
    var b = document.querySelector('.modal-backdrop .modal-body button.ss-trigger.input');
    if (!b) {
      var bs = document.querySelectorAll('.modal-body button.ss-trigger');
      if (bs.length > 0) b = bs[0];
    }
    if (!b){
      // fallback: أي button داخل modal-body div:nth-child(2)
      b = document.querySelector('.modal-body > div:nth-child(2) button');
    }
    if (!b) return 'no-btn';
    b.click();
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: Search user ═══════
  static const searchUser = r'''
(function(){
  try {
    var q = %QUERY%;
    var inp = document.querySelector('.modal-body .ss-pop input.input[role="combobox"], .modal-body .ss-pop input.input, .modal-body input[role="combobox"]');
    if (!inp) {
      var all = document.querySelectorAll('.modal-body input[role="combobox"]');
      if (all.length > 0) inp = all[all.length - 1];
    }
    if (!inp) return 'no-input';
    var setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    inp.focus();
    try { setter.call(inp, q); } catch(e){ inp.value = q; }
    inp.dispatchEvent(new Event('input', {bubbles:true}));
    inp.dispatchEvent(new Event('change', {bubbles:true}));
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: Select user from list ═══════
  static const selectUser = r'''
(function(){
  try {
    var name = %NAME%;
    var items = document.querySelectorAll('.modal-body .ss-item, .ss-pop .ss-item');
    for (var i=0;i<items.length;i++){
      var s = items[i].querySelector('span');
      var t = s ? (s.innerText||'').trim() : '';
      if (t === name){
        items[i].click();
        return 'ok';
      }
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: Confirm ═══════
  static const confirmAdd = r'''
(function(){
  try {
    var b = document.querySelector('.modal-backdrop .modal-footer button.btn.btn-primary');
    if (!b) {
      var all = document.querySelectorAll('.modal-footer button.btn-primary');
      if (all.length > 0) b = all[0];
    }
    if (!b) return 'no-btn';
    b.click();
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Modal: Check open ═══════
  static const isModalOpen = r'''
(function(){ return document.querySelector('.modal-backdrop') ? 'yes' : 'no'; })()
''';
}