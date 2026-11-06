// ==UserScript==
// @name         iFlytek ISE WS Interceptor
// @namespace    https://xtexx.eu.org/
// @version      1.0.5
// @description  Intercepts and modifies iFlytek ISE WebSocket results
// @author       xtex
// @match        *://*.fifedu.com/*
// @match        *://ucontent.unipus.cn/*
// @run-at       document-start
// @grant        none
// @supportURL   https://codeberg.org/xtex/gadgets/issues
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/ise-wss-interceptor.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/ise-wss-interceptor.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	const TARGET_WS_PREFIX = 'wss://ise-api.xfyun.cn/v2/open-ise';
	const DEBUG = true;

	const log = (...a) => DEBUG && console.log('[ise-wss-interceptor]', ...a);
	const warn = (...a) => DEBUG && console.warn('[ise-wss-interceptor]', ...a);
	const info = (...a) => DEBUG && console.info('[ise-wss-interceptor]', ...a);

	// ------------------------------------------------------------------
	// Lazy score prompt
	// undefined = not asked yet; null = declined; object = configured.
	// ------------------------------------------------------------------

	let scoreConfig;

	function ensureScoreConfig() {
		if (scoreConfig !== undefined) return scoreConfig;

		info('ISE connection detected, asking for new score...');
		const rawInput = window.prompt('Enter new score (0-100):', '94');
		if (rawInput === null) {
			scoreConfig = null;
			info('User cancelled prompt; score modification disabled.');
			return null;
		}
		const parsed = Number(rawInput);
		if (!Number.isFinite(parsed) || parsed < 0 || parsed > 100) {
			window.alert(
				'Invalid score (must be 0-100); modification disabled.'
			);
			info('Invalid input:', rawInput);
			scoreConfig = null;
			return null;
		}
		scoreConfig = {
			NEW_SCORE: parsed,
			NEW_SCORE_MAPPED: (parsed / 20).toFixed(6),
		};
		info('Config:', scoreConfig);
		return scoreConfig;
	}

	// ------------------------------------------------------------------
	// Utilities
	// ------------------------------------------------------------------

	function isScoreAttrName(name) {
		return name === 'score' || /_score$/.test(name);
	}

	function base64ToUtf8(base64) {
		const binary = atob(base64);
		const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
		return new TextDecoder('utf-8').decode(bytes);
	}

	function utf8ToBase64(str) {
		const bytes = new TextEncoder().encode(str);
		let binary = '';
		for (let i = 0; i < bytes.length; i++) {
			binary += String.fromCharCode(bytes[i]);
		}
		return btoa(binary);
	}

	function extractUpstreamContent(data) {
		if (typeof data !== 'string' || data.length === 0) return null;
		let json;
		try {
			json = JSON.parse(data);
		} catch (e) {
			return null;
		}
		if (!json || !json.business) return null;
		const text = json.business.text;
		if (typeof text !== 'string' || text.length === 0) return null;
		const m = text.match(/^\[content\]\r?\n([\s\S]*)$/);
		return m ? m[1] : text;
	}

	function randomSpeed() {
		// 140.000000 - 199.999999
		return (140 + Math.random() * 60).toFixed(6);
	}

	// ------------------------------------------------------------------
	// Build a replacement <sentence> matching the reference structure
	// ------------------------------------------------------------------

	function buildFakeSentence(doc, words, config) {
		const sentence = doc.createElement('sentence');
		sentence.setAttribute('accuracy_score', config.NEW_SCORE_MAPPED);
		sentence.setAttribute('beg_pos', '0');
		sentence.setAttribute('content', words.join(' '));
		sentence.setAttribute('end_pos', '0');
		sentence.setAttribute('fluency_score', config.NEW_SCORE_MAPPED);
		sentence.setAttribute('index', '0');
		sentence.setAttribute('standard_score', config.NEW_SCORE_MAPPED);
		sentence.setAttribute('total_score', config.NEW_SCORE_MAPPED);
		sentence.setAttribute('word_count', String(words.length));

		words.forEach((word, idx) => {
			const wordEl = doc.createElement('word');
			wordEl.setAttribute('beg_pos', '0');
			wordEl.setAttribute('content', word);
			wordEl.setAttribute('dp_message', '16');
			wordEl.setAttribute('end_pos', '0');
			wordEl.setAttribute('global_index', String(idx));
			wordEl.setAttribute('index', String(idx));
			wordEl.setAttribute('property', '0');
			wordEl.setAttribute('total_score', config.NEW_SCORE_MAPPED);

			const syll = doc.createElement('syll');
			syll.setAttribute('beg_pos', '0');
			syll.setAttribute('content', word);
			syll.setAttribute('end_pos', '0');
			syll.setAttribute('serr_msg', '1');
			syll.setAttribute('syll_accent', '0');
			syll.setAttribute('syll_score', config.NEW_SCORE_MAPPED);

			const phone = doc.createElement('phone');
			phone.setAttribute('beg_pos', '0');
			phone.setAttribute('content', word);
			phone.setAttribute('end_pos', '0');
			syll.appendChild(phone);

			wordEl.appendChild(syll);
			sentence.appendChild(wordEl);
		});

		return sentence;
	}

	// ------------------------------------------------------------------
	// XML modification paths
	// ------------------------------------------------------------------

	/**
	 * is_rejected=true path.
	 * Patch the original XML in place (do NOT rebuild from scratch):
	 *  - inner <read_chapter> (inside <rec_paper>):
	 *      is_rejected      -> false
	 *      reject_type      -> 64
	 *      speeking_speed   -> random 140-200
	 *      except_info      -> 28676
	 *      content          -> upstream content (original case)
	 *      word_count       -> word count
	 *  - replace its <sentence> with a freshly-built one from the lowercase
	 *    upstream content (word / syll / phone structure per the reference)
	 *  - rewrite every score attribute to NEW_SCORE_MAPPED
	 */
	function modifyRejectedXml(xml, config, upstreamContent) {
		const parser = new DOMParser();
		const doc = parser.parseFromString(xml, 'text/xml');
		if (doc.querySelector('parsererror')) {
			warn('modifyRejectedXml: XML parse error, passing through');
			return xml;
		}

		const trimmed = upstreamContent.trim();
		const lowerContent = trimmed.toLowerCase();
		const words = lowerContent.split(/\s+/).filter(Boolean);
		if (words.length === 0) {
			warn('modifyRejectedXml: empty upstream content, skipping');
			return xml;
		}

		// Patch inner <read_chapter> elements (nested inside <rec_paper>)
		const innerRCs = doc.querySelectorAll('rec_paper > read_chapter');
		if (innerRCs.length === 0) {
			warn(
				'modifyRejectedXml: no inner <read_chapter> found under <rec_paper>'
			);
		}
		innerRCs.forEach((rc) => {
			rc.setAttribute('content', trimmed);
			rc.setAttribute('is_rejected', 'false');
			rc.setAttribute('reject_type', '64');
			rc.setAttribute('speeking_speed', randomSpeed());
			rc.setAttribute('except_info', '28676');
			rc.setAttribute('word_count', String(words.length));

			const oldSentence = rc.querySelector('sentence');
			if (oldSentence) {
				const newSentence = buildFakeSentence(doc, words, config);
				rc.replaceChild(newSentence, oldSentence);
			} else {
				rc.appendChild(buildFakeSentence(doc, words, config));
			}
		});

		// Rewrite every score attribute across the whole XML
		const all = doc.getElementsByTagName('*');
		for (let i = 0; i < all.length; i++) {
			const el = all[i];
			for (let j = 0; j < el.attributes.length; j++) {
				const attr = el.attributes[j];
				if (
					isScoreAttrName(attr.name) &&
					attr.value !== config.NEW_SCORE_MAPPED
				) {
					attr.value = config.NEW_SCORE_MAPPED;
				}
			}
		}

		let result = new XMLSerializer().serializeToString(doc);
		if (!result.startsWith('<?xml')) {
			result = '<?xml version="1.0" encoding="UTF-8"?>\n' + result;
		}
		return result;
	}

	/**
	 * Normal (non-rejected) path: only rewrite score attributes and lowercase
	 * the top-level <sentence> content from <read_chapter content>.
	 */
	function modifyNormalXml(xml, config) {
		const parser = new DOMParser();
		const doc = parser.parseFromString(xml, 'text/xml');
		if (doc.querySelector('parsererror')) {
			warn('modifyNormalXml: XML parse error, passing through');
			return xml;
		}

		let sentenceContent = null;
		const readChapter = doc.getElementsByTagName('read_chapter')[0];
		if (readChapter) {
			const rcContent = readChapter.getAttribute('content');
			if (rcContent != null) {
				sentenceContent = rcContent
					.toLowerCase()
					.replace(/[.!?]+$/, '')
					.trim();
			}
		}

		const all = doc.getElementsByTagName('*');
		for (let i = 0; i < all.length; i++) {
			const el = all[i];
			for (let j = 0; j < el.attributes.length; j++) {
				const attr = el.attributes[j];
				if (
					isScoreAttrName(attr.name) &&
					attr.value !== config.NEW_SCORE_MAPPED
				) {
					attr.value = config.NEW_SCORE_MAPPED;
				}
			}
		}

		if (sentenceContent != null) {
			const sentences = doc.getElementsByTagName('sentence');
			for (let i = 0; i < sentences.length; i++) {
				sentences[i].setAttribute('content', sentenceContent);
			}
		}

		let result = new XMLSerializer().serializeToString(doc);
		if (!result.startsWith('<?xml')) {
			result = '<?xml version="1.0" encoding="UTF-8"?>\n' + result;
		}
		return result;
	}

	function modifyXml(xml, config, upstreamContent) {
		if (!config) return xml;
		if (typeof xml !== 'string' || xml.length === 0) return xml;

		const parser = new DOMParser();
		const doc = parser.parseFromString(xml, 'text/xml');
		if (doc.querySelector('parsererror')) {
			warn('modifyXml: XML parse error, passing through');
			return xml;
		}

		// If there is no human voice in the uploaded sound stream,
		// or for some other unknown random reasons, the server may
		// reject to judge. In this case we have to generate a dummy
		// response.
		let hasRejection = false;
		const checkEls = doc.getElementsByTagName('*');
		for (let i = 0; i < checkEls.length; i++) {
			if (checkEls[i].getAttribute('is_rejected') === 'true') {
				hasRejection = true;
				break;
			}
		}

		if (hasRejection) {
			if (!upstreamContent) {
				warn(
					'modifyXml: is_rejected=true but no upstream content captured, falling back'
				);
				return modifyNormalXml(xml, config);
			}
			info(
				'modifyXml: is_rejected=true, patching in place from upstream content'
			);
			return modifyRejectedXml(xml, config, upstreamContent);
		}

		return modifyNormalXml(xml, config);
	}

	// ------------------------------------------------------------------
	// ISE message handling
	// ------------------------------------------------------------------

	function modifyIseMessage(data, config, upstreamContent) {
		if (!config) return data;
		if (typeof data !== 'string' || data.length === 0) return data;

		let json;
		try {
			json = JSON.parse(data);
		} catch (e) {
			return data;
		}

		if (!json || json.code !== 0 || !json.data) return data;
		if (Number(json.data.status) !== 2) return data;
		if (typeof json.data.data !== 'string') return data;

		try {
			const xml = base64ToUtf8(json.data.data);
			info('modifyIseMessage: got ISE result XML:', xml);
			const newXml = modifyXml(xml, config, upstreamContent);
			if (newXml === xml) return data;
			json.data.data = utf8ToBase64(newXml);
			info('modifyIseMessage: ISE result XML modified:', newXml);
			return JSON.stringify(json);
		} catch (e) {
			warn('modifyIseMessage: failed to modify ISE payload:', e);
			return data;
		}
	}

	// ------------------------------------------------------------------
	// Hook WebSocket (iFlytek ISE results only)
	// ------------------------------------------------------------------

	const OrigWebSocket = window.WebSocket;
	if (typeof OrigWebSocket === 'function') {
		function WrappedWebSocket(url, protocols) {
			const urlStr = typeof url === 'string' ? url : String(url);
			const isTarget = urlStr.startsWith(TARGET_WS_PREFIX);

			// If ensureScoreConfig is called after establishing the connection,
			// some messages may be skipped and scripts are not working properly.
			const config = isTarget ? ensureScoreConfig() : null;

			const ws = new OrigWebSocket(url, protocols);
			if (!isTarget || !config) return ws;

			info('WebSocket: wrapping target connection:', urlStr);

			// Hook send to capture C-to-S exam content
			let upstreamContent = null;
			const origSend = ws.send.bind(ws);
			ws.send = function (data) {
				try {
					const c = extractUpstreamContent(data);
					if (c) {
						upstreamContent = c;
						info(
							'WS send: captured upstream content:',
							upstreamContent
						);
					}
				} catch (e) {
					warn('WS send: error while extracting content:', e);
				}
				return origSend(data);
			};

			const messageListeners = new Map(); // listener -> { once }
			let onmessageHandler = null;

			const origAdd = ws.addEventListener.bind(ws);
			const origRemove = ws.removeEventListener.bind(ws);

			ws.addEventListener = function (type, listener, options) {
				if (type === 'message') {
					let once = false;
					if (
						options &&
						typeof options === 'object' &&
						options.once
					) {
						once = true;
					}
					messageListeners.set(listener, { once });
					return;
				}
				return origAdd(type, listener, options);
			};

			ws.removeEventListener = function (type, listener, options) {
				if (type === 'message') {
					messageListeners.delete(listener);
					return;
				}
				return origRemove(type, listener, options);
			};

			Object.defineProperty(ws, 'onmessage', {
				get() {
					return onmessageHandler;
				},
				set(fn) {
					onmessageHandler = fn;
				},
				configurable: true,
				enumerable: true,
			});

			origAdd('message', function (event) {
				let data = event.data;
				try {
					const modified = modifyIseMessage(
						data,
						config,
						upstreamContent
					);
					if (modified !== data) {
						data = modified;
					}
				} catch (e) {
					warn('WSS: error while modifying message:', e);
				}

				const newEvent = new MessageEvent('message', {
					data: data,
					origin: event.origin,
					lastEventId: event.lastEventId,
					source: event.source,
					ports: event.ports,
				});

				const entries = Array.from(messageListeners.entries());
				for (const [listener, opts] of entries) {
					if (opts.once) {
						messageListeners.delete(listener);
					}
					try {
						if (typeof listener === 'function') {
							listener.call(ws, newEvent);
						} else if (
							listener &&
							typeof listener.handleEvent === 'function'
						) {
							listener.handleEvent(newEvent);
						}
					} catch (e) {
						warn('WSS: listener error:', e);
					}
				}

				if (typeof onmessageHandler === 'function') {
					try {
						onmessageHandler.call(ws, newEvent);
					} catch (e) {
						warn('WSS: onmessage error:', e);
					}
				}
			});

			return ws;
		}

		WrappedWebSocket.prototype = OrigWebSocket.prototype;
		Object.setPrototypeOf(WrappedWebSocket, OrigWebSocket);
		window.WebSocket = WrappedWebSocket;
		info('WebSocket hooked successfully');
	} else {
		warn('WebSocket is not available, skipping hook');
	}

	info('ISE interceptor ready');
})();
