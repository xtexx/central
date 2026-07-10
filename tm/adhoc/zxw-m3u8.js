// ==UserScript==
// @name         智学网m3u8导出
// @namespace    http://zxm3u8.local/
// @version      2026-07-11
// @description  智学网m3u8导出
// @match        https://www.zhi10.com/*
// @run-at       document-start
// @grant        GM_setClipboard
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/main/tm/adhoc/zxw-m3u8.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/main/tm/adhoc/zxw-m3u8.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	let xhrHook = false;
	function addXHRListener() {
		if (xhrHook) return;
		xhrHook = true;

		const origOpen = XMLHttpRequest.prototype.open;
		window.XMLHttpRequest.prototype.open = function () {
			this.url = arguments[1];
			this.addEventListener('load', function () {
				let url = this.url;
				if (
					url.indexOf('videocloud.zhi10.com') >= 0 &&
					url.indexOf('.m3u8') >= 0
				) {
					GM_setClipboard(url.toString(), 'text', () =>
						alert('发现智学网视频！链接已复制：' + url)
					);
				}
			});
			return origOpen.apply(this, arguments);
		};
	}
	addXHRListener();
})();
