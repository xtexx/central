// ==UserScript==
// @name         U校园voiceEvaluation拦截
// @namespace    https://xtexx.eu.org/
// @version      1.2.0
// @description  U校园API数据后处理
// @author       xtex
// @match        https://ucontent.unipus.cn/*
// @run-at       document-start
// @grant        unsafeWindow
// @supportURL   https://codeberg.org/xtex/gadgets/issues
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/unipus-voice-scores.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/unipus-voice-scores.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	const W = typeof unsafeWindow !== 'undefined' ? unsafeWindow : window;
	const TARGETS = [
		'/course/api/v3/voiceEvaluation',
		'/course/api/v3/newExploration/submit',
	];
	const FULL_PCT = 100;
	const FULL_RATIO = 1;
	const TAG = '[voiceEvalModifier]';
	const MODIFY_ASR_DETAIL = true;
	const VERBOSE_LOG = true;

	function isTarget(url) {
		return (
			typeof url === 'string' &&
			TARGETS.some((t) => url.indexOf(t) !== -1)
		);
	}

	function buildAsrTable(details) {
		return (
			'<table border="1"><tr><th>单词</th><th>打分</th></tr>' +
			details
				.map(
					(it) =>
						`<tr><td>${it.char ?? ''}</td><td>${FULL_PCT}</td></tr>`
				)
				.join('') +
			'</table>'
		);
	}

	function deepMax(obj, seen, changes, path) {
		if (!obj || typeof obj !== 'object') return;
		if (seen.has(obj)) return;
		seen.add(obj);

		const isArr = Array.isArray(obj);

		if (!isArr) {
			if (
				obj.specific_scores &&
				typeof obj.specific_scores === 'object'
			) {
				const ss = obj.specific_scores;
				[
					'total',
					'accuracy',
					'integrity',
					'fluency',
					'relevance',
				].forEach((k) => {
					if (k in ss && ss[k] !== FULL_RATIO) {
						changes.push({
							path: `${path}.specific_scores.${k}`,
							from: ss[k],
							to: FULL_RATIO,
						});
						ss[k] = FULL_RATIO;
					}
				});
			}

			if (obj.recordDetail && typeof obj.recordDetail === 'object') {
				const rd = obj.recordDetail;
				[
					'score',
					'smooth',
					'completed',
					'correctness',
					'relevance',
				].forEach((k) => {
					if (k in rd && rd[k] !== FULL_PCT) {
						changes.push({
							path: `${path}.recordDetail.${k}`,
							from: rd[k],
							to: FULL_PCT,
						});
						rd[k] = FULL_PCT;
					}
				});

				if (MODIFY_ASR_DETAIL) {
					if (Array.isArray(rd.details)) {
						rd.details.forEach((it, i) => {
							if (
								it &&
								typeof it === 'object' &&
								'score' in it &&
								it.score !== FULL_PCT
							) {
								changes.push({
									path: `${path}.recordDetail.details[${i}].score <${it.char ?? ''}>`,
									from: it.score,
									to: FULL_PCT,
								});
								it.score = FULL_PCT;
							}
						});
						if (
							typeof rd.asrDetail === 'string' &&
							rd.asrDetail.length
						) {
							const newAsr = buildAsrTable(rd.details);
							if (newAsr !== rd.asrDetail) {
								changes.push({
									path: `${path}.recordDetail.asrDetail`,
									from: `(html table, ${rd.details.length} word(s))`,
									to: `(regenerated, ${rd.details.length} word(s) @ ${FULL_PCT})`,
								});
								rd.asrDetail = newAsr;
							}
						}
					}
					if (Array.isArray(rd.detailsWords)) {
						rd.detailsWords.forEach((it, i) => {
							if (
								it &&
								typeof it === 'object' &&
								'score' in it &&
								it.score !== FULL_PCT
							) {
								changes.push({
									path: `${path}.recordDetail.detailsWords[${i}].score`,
									from: it.score,
									to: FULL_PCT,
								});
								it.score = FULL_PCT;
							}
						});
					}
				}
			}

			if (
				typeof obj.score === 'number' &&
				!('char' in obj) &&
				!('word' in obj) &&
				obj.score !== FULL_PCT
			) {
				changes.push({
					path: `${path}.score`,
					from: obj.score,
					to: FULL_PCT,
				});
				obj.score = FULL_PCT;
			}
		}

		Object.keys(obj).forEach((k) => {
			const v = obj[k];
			const childPath = isArr ? `${path}[${k}]` : `${path}.${k}`;
			if (v && typeof v === 'object') {
				if (!seen.has(v)) deepMax(v, seen, changes, childPath);
			} else if (typeof v === 'string') {
				const t = v.trim();
				if (t.startsWith('{') || t.startsWith('[')) {
					let parsed;
					try {
						parsed = JSON.parse(v);
					} catch (e) {
						return;
					}
					if (parsed && typeof parsed === 'object') {
						const before = changes.length;
						deepMax(parsed, seen, changes, `${childPath}(JSON)`);
						if (changes.length > before) {
							obj[k] = JSON.stringify(parsed);
						}
					}
				}
			}
		});
	}

	function rewriteBody(body) {
		const result = { body, changes: [] };
		if (typeof body !== 'string' || !body) return result;

		let outer;
		try {
			outer = JSON.parse(body);
		} catch (e) {
			console.warn(`${TAG} body is not valid JSON, skipped`);
			return result;
		}
		if (!outer || typeof outer !== 'object') return result;

		deepMax(outer, new WeakSet(), result.changes, '$');

		if (result.changes.length === 0) return result;

		try {
			result.body = JSON.stringify(outer);
		} catch (e) {
			console.warn(`${TAG} failed to serialize modified body:`, e);
			result.body = body;
			result.changes = [];
		}
		return result;
	}

	function logResult(kind, url, origBody, result) {
		const changes = result.changes;
		const origSize = typeof origBody === 'string' ? origBody.length : 0;
		const newSize =
			typeof result.body === 'string' ? result.body.length : 0;

		console.groupCollapsed(
			`${TAG} [${kind}] intercepted ${url} — ${changes.length} field(s) modified`
		);
		console.log(`${TAG} [${kind}] url         : ${url}`);
		console.log(
			`${TAG} [${kind}] body size   : ${origSize} -> ${newSize} bytes`
		);
		console.log(`${TAG} [${kind}] changed     : ${changes.length}`);

		if (VERBOSE_LOG && changes.length) {
			const byCategory = {};
			changes.forEach((c) => {
				let cat = 'other';
				if (c.path.indexOf('.specific_scores.') !== -1)
					cat = 'specific_scores';
				else if (c.path.indexOf('.recordDetail.details[') !== -1)
					cat = 'recordDetail.details';
				else if (c.path.indexOf('.recordDetail.detailsWords[') !== -1)
					cat = 'recordDetail.detailsWords';
				else if (c.path.indexOf('.recordDetail.asrDetail') !== -1)
					cat = 'recordDetail.asrDetail';
				else if (c.path.indexOf('.recordDetail.') !== -1)
					cat = 'recordDetail';
				else if (/\.score$/.test(c.path)) cat = 'score';
				byCategory[cat] = (byCategory[cat] || 0) + 1;
			});
			Object.keys(byCategory).forEach((cat) => {
				console.log(`${TAG} [${kind}]   - ${cat}: ${byCategory[cat]}`);
			});

			changes.forEach((c, i) => {
				console.log(
					`${TAG} [${kind}]   #${String(i + 1).padStart(3, '0')} ${c.path}: ` +
						`${JSON.stringify(c.from)} -> ${JSON.stringify(c.to)}`
				);
			});
		}
		console.groupEnd();
	}

	const origFetch = W.fetch;
	if (typeof origFetch === 'function') {
		W.fetch = function (input, init) {
			try {
				let url = '';
				if (typeof input === 'string') {
					url = input;
				} else if (input && typeof input === 'object' && input.url) {
					url = input.url;
				}

				if (isTarget(url) && init && typeof init.body === 'string') {
					const result = rewriteBody(init.body);
					if (result.changes.length) {
						init = Object.assign({}, init, { body: result.body });
						logResult(
							'fetch',
							url,
							arguments.length > 1 ? init.body : init.body,
							result
						);
					} else {
						console.log(
							`${TAG} [fetch] no score field detected in ${url}`
						);
					}
				}
			} catch (e) {
				console.warn(`${TAG} [fetch] failed to rewrite request:`, e);
			}
			return origFetch.call(this, input, init);
		};
	}

	const OrigXHR = W.XMLHttpRequest;
	if (typeof OrigXHR === 'function') {
		const origOpen = OrigXHR.prototype.open;
		const origSend = OrigXHR.prototype.send;

		OrigXHR.prototype.open = function (method, url, ...rest) {
			this.__vemIsTarget = isTarget(url);
			this.__vemUrl = url;
			this.__vemMethod = method;
			return origOpen.call(this, method, url, ...rest);
		};

		OrigXHR.prototype.send = function (body) {
			if (this.__vemIsTarget) {
				try {
					const result = rewriteBody(body);
					if (result.changes.length) {
						this.__vemOrigBody = body;
						body = result.body;
						logResult(
							`xhr ${this.__vemMethod}`,
							this.__vemUrl,
							this.__vemOrigBody,
							result
						);
					} else {
						console.log(
							`${TAG} [xhr] no score field detected in ${this.__vemUrl}`
						);
					}
				} catch (e) {
					console.warn(`${TAG} [xhr] failed to rewrite request:`, e);
				}
			}
			return origSend.call(this, body);
		};
	}

	console.log(
		`${TAG} script loaded (asrDetail=${MODIFY_ASR_DETAIL ? 'on' : 'off'}, verbose=${VERBOSE_LOG ? 'on' : 'off'})`
	);
})();
