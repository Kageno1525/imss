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
    setTimeout(function(){ try { b.click(); } catch(e){} }, 150);
    return 'ok';
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

  // ═══════ Filter ═══════
  static const clickFilter = r'''
(function(){
  try {
    document.body.click();
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

  // ⭐⭐⭐ تغيير page size لـ 5000 — نفس طريقة IMS الأول
  static const setPageSize5000 = r'''
(function(){
  try {
    // 1) ابحث عن select اللي فيه option value="5000"
    var allSelects = document.querySelectorAll('select');
    var target = null;
    var targetIdx = -1;
    var info = [];

    for (var i=0;i<allSelects.length;i++){
      var s = allSelects[i];
      var vals = [];
      var found5000 = -1;
      for (var j=0;j<s.options.length;j++){
        vals.push(String(s.options[j].value));
        if (String(s.options[j].value) === '5000') found5000 = j;
      }
      info.push('sel' + i + '=[' + vals.join(',') + ']');
      if (found5000 >= 0){
        target = s;
        targetIdx = found5000;
        break;
      }
    }

    if (!target) return 'no-select|' + info.join('|');

    // 2) focus
    try { target.focus(); } catch(e){}

    // 3) native setter على selectedIndex
    try {
      var idxSetter = Object.getOwnPropertyDescriptor(
        HTMLSelectElement.prototype, 'selectedIndex'
      ).set;
      idxSetter.call(target, targetIdx);
    } catch(e){
      target.selectedIndex = targetIdx;
    }

    // 4) native setter على value
    try {
      var vSetter = Object.getOwnPropertyDescriptor(
        HTMLSelectElement.prototype, 'value'
      ).set;
      vSetter.call(target, '5000');
    } catch(e){
      target.value = '5000';
    }

    // 5) تأكيد يدوي
    for (var m=0;m<target.options.length;m++){
      target.options[m].selected = (m === targetIdx);
    }
    try { target.selectedIndex = targetIdx; } catch(e){}

    // 6) إطلاق كل الأحداث
    try { target.dispatchEvent(new Event('focus', {bubbles:true})); } catch(e){}
    try { target.dispatchEvent(new Event('input', {bubbles:true, cancelable:true})); } catch(e){}
    try { target.dispatchEvent(new Event('change', {bubbles:true, cancelable:true})); } catch(e){}
    try { target.dispatchEvent(new UIEvent('change', {bubbles:true})); } catch(e){}
    try { target.dispatchEvent(new Event('blur', {bubbles:true})); } catch(e){}
    try { target.dispatchEvent(new Event('focusout', {bubbles:true})); } catch(e){}
    try { target.blur(); } catch(e){}

    return 'ok|value=' + target.value + '|idx=' + target.selectedIndex;
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ⭐⭐⭐ قراءة الحالة الحالية
  static const readPageState = r'''
(function(){
  try {
    var total = 0;
    var pg = document.querySelector('.pg-left');
    var pgText = pg ? (pg.innerText||'').trim() : '';
    var m = pgText.match(/of\s+([\d,]+)/i);
    if (m) total = parseInt(m[1].replace(/,/g,''), 10);

    var rows = document.querySelectorAll('table tr.vrow').length;

    // آخر صفحة في الـ paginator
    var currentPage = '?';
    var curBtn = document.querySelector('.paginator-controls button.pg-num.is-current');
    if (curBtn) currentPage = (curBtn.innerText||'').trim();

    return JSON.stringify({
      total: total,
      rowsOnPage: rows,
      pgText: pgText,
      currentPage: currentPage
    });
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ⭐⭐⭐ الإحصائيات النهائية — المضاف = الكلي - المتاح
  static const readFinalStats = r'''
(function(){
  try {
    // 1) العدد الكلي
    var total = 0;
    var pg = document.querySelector('.pg-left');
    if (pg){
      var m = (pg.innerText||'').match(/of\s+([\d,]+)/i);
      if (m) total = parseInt(m[1].replace(/,/g,''), 10);
    }

    // 2) فهرس عمود Client
    var table = document.querySelector('table');
    if (!table){
      return JSON.stringify({
        total: total, available: 0, added: total, rows: 0, clientIdx: -1
      });
    }

    var clientIdx = -1;
    var ths = table.querySelectorAll('th');
    for (var i=0;i<ths.length;i++){
      var clone = ths[i].cloneNode(true);
      var ex = clone.querySelectorAll('span, svg');
      for (var x=0;x<ex.length;x++) ex[x].remove();
      var t = (clone.innerText||clone.textContent||'').trim();
      if (t === 'Client'){ clientIdx = i; break; }
    }

    // 3) عد المتاح
    var rows = table.querySelectorAll('tr.vrow');
    var available = 0;
    if (clientIdx >= 0){
      for (var r=0;r<rows.length;r++){
        var tds = rows[r].querySelectorAll('td');
        if (clientIdx >= tds.length) continue;
        var c2 = tds[clientIdx].cloneNode(true);
        var ex2 = c2.querySelectorAll('button, svg');
        for (var k=0;k<ex2.length;k++) ex2[k].remove();
        var v = (c2.innerText||c2.textContent||'').trim();
        if (v === '-' || v === '' || v === '—' || v === '–') available++;
      }
    }

    // 4) المضاف = الكلي - المتاح
    var added = total - available;
    if (added < 0) added = 0;

    return JSON.stringify({
      total: total,
      available: available,
      added: added,
      rows: rows.length,
      clientIdx: clientIdx
    });
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Check Available ═══════
  static const checkAvailable = r'''
(function(){
  try {
    var n = %COUNT%;
    var clientIdx = -1;
    var ths = document.querySelectorAll('table th');
    for (var i=0;i<ths.length;i++){
      var clone = ths[i].cloneNode(true);
      var spans = clone.querySelectorAll('span, svg');
      for (var x=0;x<spans.length;x++) spans[x].remove();
      var t = (clone.innerText || clone.textContent || '').trim();
      if (t === 'Client'){ clientIdx = i; break; }
    }
    if (clientIdx < 0) return 'no-column';

    var rows = document.querySelectorAll('tr.vrow');
    var checked = 0;
    for (var r=0;r<rows.length && checked < n;r++){
      var row = rows[r];
      var tds = row.querySelectorAll('td');
      if (clientIdx >= tds.length) continue;
      var clone2 = tds[clientIdx].cloneNode(true);
      var extra = clone2.querySelectorAll('button, svg');
      for (var k=0;k<extra.length;k++) extra[k].remove();
      var v = (clone2.innerText || clone2.textContent || '').trim();
      if (v === '-' || v === '' || v === '—' || v === '–'){
        var cb = row.querySelector('input.checkbox');
        if (cb && !cb.checked){ cb.click(); checked++; }
      }
    }
    return 'ok|checked=' + checked;
  } catch(e){ return 'err:' + e.message; }
})()
''';

  // ═══════ Add Flow ═══════
  static const clickAddButton = r'''
(function(){
  try {
    var b = document.querySelector('.head-actions button.btn.btn-primary');
    if (b){ b.click(); return 'ok'; }
    return 'no-btn';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const selectDlr7_1 = r'''
(function(){
  try {
    var sels = document.querySelectorAll('.modal-body select.select, select.select, select');
    for (var i=0;i<sels.length;i++){
      var s = sels[i];
      var idx = -1;
      for (var j=0;j<s.options.length;j++){
        if (String(s.options[j].value) === '7-1'){ idx = j; break; }
      }
      if (idx < 0) continue;
      try {
        var setter = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set;
        setter.call(s, '7-1');
      } catch(e){ s.value = '7-1'; }
      s.selectedIndex = idx;
      for (var k=0;k<s.options.length;k++) s.options[k].selected = (k === idx);
      s.dispatchEvent(new Event('input', {bubbles:true}));
      s.dispatchEvent(new Event('change', {bubbles:true}));
      return 'ok';
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const openUserDropdown = r'''
(function(){
  try {
    var b = document.querySelector('.modal-backdrop .modal-body button.ss-trigger.input');
    if (!b) {
      var bs = document.querySelectorAll('.modal-body button.ss-trigger');
      if (bs.length > 0) b = bs[0];
    }
    if (!b) b = document.querySelector('.modal-body > div:nth-child(2) button');
    if (!b) return 'no-btn';
    b.click();
    return 'ok';
  } catch(e){ return 'err:' + e.message; }
})()
''';

  static const searchUser = r'''
(function(){
  try {
    var q = %QUERY%;
    var inp = document.querySelector('.modal-body .ss-pop input.input[role="combobox"], .modal-body .ss-pop input.input');
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

  static const selectUser = r'''
(function(){
  try {
    var name = %NAME%;
    var items = document.querySelectorAll('.modal-body .ss-item, .ss-pop .ss-item');
    for (var i=0;i<items.length;i++){
      var s = items[i].querySelector('span');
      var t = s ? (s.innerText||'').trim() : '';
      if (t === name){ items[i].click(); return 'ok'; }
    }
    return 'not-found';
  } catch(e){ return 'err:' + e.message; }
})()
''';

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
}