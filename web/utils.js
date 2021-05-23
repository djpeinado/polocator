function loadScriptDefer(url) {
  document.write('<script defer type="text/javascript" src="' + url + '"><\/scr' + 'ipt>');
}

function getFirebaseJSModuleURL(version, module) {
  return 'https://www.gstatic.com/firebasejs/' + version + '/firebase-' + module + '.js';
}

function loadScriptFirebase(version, module) {
  loadScriptDefer(getFirebaseJSModuleURL(version, module));
}