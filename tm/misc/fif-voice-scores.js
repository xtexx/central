// ==UserScript==
// @name         FIF Learning Platform Score Interceptor
// @namespace    https://xtexx.eu.org/
// @version      1.0.4
// @description  Intercepts submitExerciseResults
// @author       xtex
// @match        *://*.fifedu.com/*
// @run-at       document-start
// @grant        none
// @supportURL   https://codeberg.org/xtex/gadgets/issues
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/fif-voice-scores.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/fif-voice-scores.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	const TARGET_HOST = 'moral.fifedu.com';
	const TARGET_PATH = '/kyxl-app-challenge/evaluation/submitExerciseResults';
	const FIELDS = ['semantic', 'accuracy', 'fluency', 'complete', 'score'];
	const NEW_VALUE = 94;
	const DEBUG = true;

	const log = (...a) => DEBUG && console.log('[fif-interceptor]', ...a);
	const warn = (...a) => DEBUG && console.warn('[fif-interceptor]', ...a);
	const info = (...a) => DEBUG && console.info('[fif-interceptor]', ...a);

	info('Script starting with config:', {
		TARGET_HOST,
		TARGET_PATH,
		FIELDS,
		NEW_VALUE,
		DEBUG,
	});

	function isTarget(url) {
		if (!url) return false;
		try {
			const u = new URL(url, location.href);
			const matched =
				u.hostname === TARGET_HOST && u.pathname === TARGET_PATH;
			if (matched) info('isTarget: matched ->', u.href);
			return matched;
		} catch (e) {
			warn('isTarget: failed to parse URL:', url, e);
			return false;
		}
	}

	function modifyBody(body) {
		log('modifyBody: incoming body length =', body ? body.length : 0);

		if (typeof body !== 'string' || body.length === 0) {
			warn('modifyBody: body is empty or not a string, passing through');
			return body;
		}

		if (!body.includes('resultJson=')) {
			warn(
				'modifyBody: no "resultJson=" in body, likely not urlencoded, passing through'
			);
			return body;
		}

		const params = new URLSearchParams(body);
		let json;
		try {
			json = JSON.parse(params.get('resultJson'));
		} catch (e) {
			warn('modifyBody: failed to parse resultJson, passing through:', e);
			return body;
		}

		log('modifyBody: parsed resultJson =', json);
		FIELDS.forEach((f) => {
			const oldValue = json[f];
			json[f] = NEW_VALUE;
			log(`modifyBody: field "${f}" ${oldValue} -> ${NEW_VALUE}`);
		});

		params.set('resultJson', JSON.stringify(json));
		const newBody = params.toString();
		info(
			'modifyBody: resultJson modified. New body length =',
			newBody.length
		);
		return newBody;
	}

	const origFetch = window.fetch;
	if (typeof origFetch === 'function') {
		window.fetch = function (input, init) {
			let nextInit = init;
			try {
				const isRequest =
					typeof Request !== 'undefined' && input instanceof Request;
				const url =
					typeof input === 'string'
						? input
						: isRequest
							? input.url
							: String(input);
				const method = (
					(init && init.method) ||
					(isRequest && input.method) ||
					'GET'
				).toUpperCase();

				log('fetch intercepted:', method, url);

				if (method !== 'POST' || !isTarget(url)) {
					log('fetch: not modified (method/url condition not met)');
				} else if (init && typeof init.body === 'string') {
					info('fetch: target POST detected, modifying request body');
					nextInit = Object.assign({}, init, {
						body: modifyBody(init.body),
					});
					info('fetch: request body replaced');
				} else if (isRequest) {
					warn(
						'fetch: Request object body detected, unable to modify synchronously. Consider rewriting via clone().'
					);
				} else {
					warn('fetch: no string body in init, passing through');
				}
			} catch (e) {
				warn('fetch: error while handling interception:', e);
			}
			return origFetch.call(this, input, nextInit);
		};
		info('fetch hooked successfully');
	} else {
		warn('fetch is not available, skipping hook');
	}

	const origOpen = XMLHttpRequest.prototype.open;
	const origSend = XMLHttpRequest.prototype.send;

	XMLHttpRequest.prototype.open = function (method, url) {
		this.__intercept_method = method;
		this.__intercept_url = url;
		log('XHR open:', String(method).toUpperCase(), url);
		return origOpen.apply(this, arguments);
	};

	XMLHttpRequest.prototype.send = function (body) {
		let nextBody = body;
		try {
			if (
				this.__intercept_method &&
				String(this.__intercept_method).toUpperCase() === 'POST' &&
				isTarget(this.__intercept_url)
			) {
				info('XHR send: target POST detected, modifying request body');
				nextBody = modifyBody(body);
				info('XHR send: request body replaced');
			}
		} catch (e) {
			warn('XHR send: error while handling interception:', e);
		}
		return origSend.call(this, nextBody);
	};
	info('XMLHttpRequest hooked successfully');

	const origBeacon = navigator.sendBeacon;
	if (typeof origBeacon === 'function') {
		navigator.sendBeacon = function (url, data) {
			let nextData = data;
			try {
				if (isTarget(url) && typeof data === 'string') {
					info('sendBeacon: target detected, modifying payload');
					nextData = modifyBody(data);
				}
			} catch (e) {
				warn('sendBeacon: error while handling interception:', e);
			}
			return origBeacon.call(this, url, nextData);
		};
		info('sendBeacon hooked successfully');
	}

	info('Script ready, waiting for target requests...');
})();
