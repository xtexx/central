// ==UserScript==
// @name         iTEST Helper
// @namespace    https://xtexx.eu.org/
// @version      1.0.6
// @description  Utilities for iTEST
// @author       xtex
// @match        *://itestcloud.unipus.cn/*
// @run-at       document-start
// @grant        none
// @supportURL   https://codeberg.org/xtex/gadgets/issues
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/itest-helper.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/itest-helper.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	const DEBUG = true;

	const log = (...a) => DEBUG && console.log('[itest-helper]', ...a);
	const warn = (...a) => DEBUG && console.warn('[itest-helper]', ...a);
	const info = (...a) => DEBUG && console.info('[itest-helper]', ...a);

	const EXAM_PAPER_URL =
		'itestcloud.unipus.cn/itest-api/itest/s/answer/index';
	const ANSWER_PAGE_URL =
		'itestcloud.unipus.cn/utest/itest/biz/exam/papershow/showPaper';
	const pageType =
		location.href.indexOf(EXAM_PAPER_URL) !== -1
			? 'exam-paper'
			: location.href.indexOf(ANSWER_PAGE_URL) !== -1
				? 'answer'
				: 'unknown';

	log('script loaded', { url: location.href, pageType });

	/* ========== Focus bypass interceptor ========== */
	const FocusBypass = (function () {
		const UNFOCUS_REPORT_URL =
			'://itestcloud.unipus.cn/itest-api/itest/s/answer/screen/switch';
		const ALERT_TEXT = '离开考试页面，老师将收到异常报告！';

		let enabled = false;
		let pollTimer = null;
		let origAjax = null;
		let ajaxWrapped = null;
		let origAlert = null;
		let alertWrapped = null;

		function isTargetUrl(url) {
			if (typeof url !== 'string') return false;
			let abs;
			try {
				abs = new URL(url, location.href).href;
			} catch (e) {
				abs = url;
			}
			return abs.indexOf(UNFOCUS_REPORT_URL) === 0;
		}

		function hookAjax() {
			const $ = window.jQuery;
			if (!$ || !$.ajax) {
				log('hookAjax: jQuery not ready');
				return false;
			}
			if ($.ajax.__screenHijacked) {
				log('hookAjax: already hooked');
				return true;
			}

			origAjax = $.ajax;
			ajaxWrapped = function (opts) {
				try {
					if (opts && isTargetUrl(opts.url)) {
						log('intercepted ajax ->', opts.url);
						const fake = { code: -1 };
						setTimeout(function () {
							try {
								if (typeof opts.success === 'function')
									opts.success(fake, 'success', {
										status: 200,
									});
								if (typeof opts.complete === 'function')
									opts.complete({ status: 200 }, 'success');
							} catch (e) {
								warn('callback error', e);
							}
						}, 0);
						return {
							abort: function () {
								return this;
							},
							done: function () {
								return this;
							},
							fail: function () {
								return this;
							},
							always: function () {
								return this;
							},
							then: function () {
								return this;
							},
						};
					}
				} catch (e) {
					warn('ajax hook error', e);
				}
				return origAjax.apply(this, arguments);
			};
			ajaxWrapped.__screenHijacked = true;
			$.ajax = ajaxWrapped;
			log('hookAjax: installed');
			return true;
		}

		function removeAjaxHook() {
			const $ = window.jQuery;
			if ($ && $.ajax && $.ajax.__screenHijacked && origAjax) {
				$.ajax = origAjax;
				log('hookAjax: removed');
			}
			origAjax = null;
			ajaxWrapped = null;
		}

		function hookLayerAlert() {
			const layer = window.layer;
			if (!layer || typeof layer.alert !== 'function') {
				log('hookLayerAlert: layer not ready');
				return false;
			}
			if (layer.alert.__screenHijacked) {
				log('hookLayerAlert: already hooked');
				return true;
			}

			origAlert = layer.alert;
			alertWrapped = function (msg) {
				try {
					if (typeof msg === 'string' && msg.trim() === ALERT_TEXT) {
						log('suppressed layer.alert:', msg);
						return;
					}
				} catch (e) {}
				return origAlert.apply(this, arguments);
			};
			alertWrapped.__screenHijacked = true;
			layer.alert = alertWrapped;
			log('hookLayerAlert: installed');
			return true;
		}

		function removeLayerAlertHook() {
			const layer = window.layer;
			if (
				layer &&
				typeof layer.alert === 'function' &&
				layer.alert.__screenHijacked &&
				origAlert
			) {
				layer.alert = origAlert;
				log('hookLayerAlert: removed');
			}
			origAlert = null;
			alertWrapped = null;
		}

		function tryInstall() {
			return hookAjax() && hookLayerAlert();
		}

		function enable() {
			if (enabled) {
				log('enable: already enabled');
				return;
			}
			enabled = true;
			log('enable: enabling interceptor');
			if (tryInstall()) {
				log('enable: installed immediately');
				return;
			}
			if (pollTimer) return;

			let n = 0;
			pollTimer = setInterval(function () {
				if (!enabled) {
					clearInterval(pollTimer);
					pollTimer = null;
					return;
				}
				if (tryInstall()) {
					log('enable: installed after', n, 'polls');
					clearInterval(pollTimer);
					pollTimer = null;
					return;
				}
				if (++n > 600) {
					warn('enable: gave up after 600 polls');
					clearInterval(pollTimer);
					pollTimer = null;
				}
			}, 100);
			log('enable: waiting for jQuery / layer...');
		}

		function disable() {
			enabled = false;
			if (pollTimer) {
				clearInterval(pollTimer);
				pollTimer = null;
			}
			removeAjaxHook();
			removeLayerAlertHook();
			log('disable: interceptor disabled');
		}

		return {
			enable: enable,
			disable: disable,
			isEnabled: function () {
				return enabled;
			},
		};
	})();

	function extractAnswers() {
		log('extractAnswers: start');
		const container = document.querySelector('main div.moduleBox');
		if (!container)
			throw new Error('extractAnswers: moduleBox container not found');

		const result = [...container.querySelectorAll('div[id]')]
			.filter((el) => /^ques-\d+$/.test(el.id))
			.map((quesEl) => {
				log('extractAnswers: processing question block', quesEl);
				const item = {
					id: Number.parseInt(quesEl.id.slice(5)),
					material: '',
					subQuestions: [],
				};

				const optionList = quesEl.querySelector(
					'[class*="optionList___"]'
				);
				item.material = (optionList?.textContent || '')
					.replace(/[ \t]+/g, ' ')
					.replace(/\n{3,}/g, '\n\n')
					.trim();

				item.subQuestions = [
					...quesEl.querySelectorAll('[class*="subQuesBox___"]'),
				].forEach((subQuesEl) => {
					const subItem = { content: '', options: [], correct: [] };

					const contentEl = subQuesEl.querySelector(
						'[class*="subQuesContent___"]'
					);
					if (contentEl)
						subItem.content = (contentEl.textContent || '')
							.replace(/\s+/g, ' ')
							.trim();

					const articleEl =
						subQuesEl.querySelector(
							'[class*="optionItem___"] article'
						) || subQuesEl.querySelector('article');
					if (articleEl) {
						[...articleEl.querySelectorAll('li')]
							.map((el) => el.cloneNode(true))
							.forEach((optEl) => {
								const varEl = optEl.querySelector('var');
								if (varEl) varEl.textContent += '. ';

								const txt = (optEl.textContent || '')
									.replace(/\s+/g, ' ')
									.trim();
								if (!txt) return;
								subItem.options.push(txt);
								if (optEl.className.indexOf('right___') !== -1)
									subItem.correct.push(txt);
							});
					}

					return subItem;
				});

				return item;
			});
		log('extractAnswers: done', result);
		return result;
	}

	function formatAnswers(items) {
		const lines = [];
		items.forEach((item) => {
			lines.push('=========================');
			lines.push(`题目编号：${item.id}`);
			if (item.material) {
				lines.push(item.material);
				lines.push('');
			}
			item.subQuestions.forEach((sub, idx) => {
				lines.push(`---- 小题 ${idx + 1}`);
				lines.push('题目：' + sub.content);
				lines.push('选项：');
				lines.push(...sub.options.map((x) => '  - ' + x));
				if (sub.correct.length === 0) {
					lines.push('正确答案：（未知）');
				} else if (sub.correct.length === 1) {
					lines.push(`正确答案：${sub.correct[0]}`);
				} else {
					lines.push('正确答案：');
					lines.push(...sub.correct.map((x) => '  - ' + x));
				}
				lines.push('');
			});
			lines.push('');
		});
		return lines.join('\n').trim();
	}

	async function copyText(text) {
		log('copyText', text);

		if (typeof GM_setClipboard === 'function') {
			log('copyText: trying GM_setClipboard');
			try {
				await GM_setClipboard(text, 'text');
				log('copyText: GM_setClipboard succeeded');
				return true;
			} catch (e) {
				warn('copyText: GM_setClipboard failed', e);
			}
		}

		if (navigator.clipboard && window.isSecureContext) {
			log('copyText: trying navigator.clipboard');
			try {
				await navigator.clipboard.writeText(text);
				log('copyText: navigator.clipboard succeeded');
				return true;
			} catch (e) {
				warn('copyText: navigator.clipboard failed', e);
			}
		}

		log('copyText: trying legacy copy');
		const ta = document.createElement('textarea');
		ta.value = text;
		ta.setAttribute('readonly', '');
		Object.assign(ta.style, {
			position: 'fixed',
			top: '-9999px',
			left: '-9999px',
			opacity: '0',
		});
		document.body.appendChild(ta);
		ta.select();
		ta.setSelectionRange(0, ta.value.length);
		let ok = false;
		try {
			ok = document.execCommand('copy');
		} catch (e) {
			ok = false;
		}
		ta.remove();
		log(`copyText: legacy result = ${ok}`);
		return ok;
	}

	const box = document.createElement('div');
	Object.assign(box.style, {
		position: 'fixed',
		left: '10px',
		top: '10px',
		zIndex: '2147483647',
		minWidth: '15em',
		background: '#f0f0f0',
		border: '1px solid #aaaaaa',
		font: '10pt/1.4 sans-serif',
		color: '#333333',
		overflow: 'hidden',
	});
	box.style.setProperty('text-autospace', 'normal');
	box.style.setProperty('text-spacing-trim', 'normal');

	/* Header */
	const header = document.createElement('div');
	Object.assign(header.style, {
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		padding: '6px 10px',
		background: '#bfbfbf',
		borderBottom: '1px solid #aaa',
		cursor: 'move',
		fontWeight: '600',
		touchAction: 'none',
	});
	header.textContent = 'iTEST助手';

	const body = document.createElement('div');
	Object.assign(body.style, { padding: '1rem' });

	function createButton(text, bg, onClick) {
		const btn = document.createElement('button');
		btn.textContent = text;
		Object.assign(btn.style, {
			width: '100%',
			padding: '7px 10px',
			border: 'none',
			background: bg,
			color: '#dddddd',
		});
		btn.addEventListener('click', onClick);
		return btn;
	}

	function flashButton(el, msg, isError) {
		if (!el.__origText) {
			el.__origText = el.textContent;
			el.__origBg = el.style.background;
		}
		el.textContent = msg;
		el.style.background = isError ? '#9a4b4b' : '#4b9a4b';
		clearTimeout(el.__tipTimer);
		el.__tipTimer = setTimeout(function () {
			el.textContent = el.__origText;
			el.style.background = el.__origBg;
		}, 1500);
	}

	if (pageType === 'exam-paper') {
		const copyQuestionBtn = createButton('复制题目', '#1677ff', () => {
			log('copy questions button clicked');
			const el = document.querySelector('.itest-ques');
			if (!el)
				return flashButton(copyQuestionBtn, '未找到.itest-ques', true);
			const text = el.textContent;
			log('copy questions', { el, text });
			copyText(text).then((success) => {
				flashButton(
					copyQuestionBtn,
					success ? '已复制' : '复制失败',
					!success
				);
			});
		});

		const unfocusSwitchRow = document.createElement('label');
		Object.assign(unfocusSwitchRow.style, {
			// display: 'flex',
			justifyContent: 'space-between',
			marginTop: '10px',
		});
		const unfocusSwitch = document.createElement('input');
		unfocusSwitch.type = 'checkbox';
		unfocusSwitch.checked = true;
		unfocusSwitch.addEventListener('change', function () {
			log('unfocus switch changed', { checked: unfocusSwitch.checked });
			if (unfocusSwitch.checked) FocusBypass.enable();
			else FocusBypass.disable();
		});
		unfocusSwitchRow.append('拦截切屏检测', unfocusSwitch);
		FocusBypass.enable();

		body.appendChild(copyQuestionBtn, unfocusSwitchRow);
	} else if (pageType === 'answer') {
		const copyAnswerBtn = createButton('复制答案', '#1677ff', () => {
			let items;
			try {
				items = extractAnswers();
			} catch (e) {
				warn('failed to extract answers', e);
				flashButton(copyAnswerBtn, '提取题目失败', true);
				return;
			}
			if (items.length === 0) {
				flashButton(copyAnswerBtn, '未找到题目', true);
				return;
			}
			const text = formatAnswers(items);
			log('formatted answers for copy', text);
			copyText(text).then((success) => {
				if (success) {
					flashButton(
						copyAnswerBtn,
						`已复制${items.length}道题`,
						false
					);
				} else {
					flashButton(copyAnswerBtn, '复制失败', true);
				}
			});
		});
		body.append(copyAnswerBtn);
	}

	box.append(header, body);
	if (pageType !== 'unknown')
		window.addEventListener('load', () => document.body.appendChild(box));
	log('float window mounted');

	// Dragging
	{
		let dragging = false,
			startX = 0,
			startY = 0,
			originalLeft = 0,
			originalTop = 0;

		header.addEventListener('pointerdown', (e) => {
			if (e.button !== 0) return;
			dragging = true;
			startX = e.clientX;
			startY = e.clientY;
			const r = box.getBoundingClientRect();
			originalLeft = r.left;
			originalTop = r.top;
			header.setPointerCapture(e.pointerId);
			e.preventDefault();
			log('drag: start at', originalLeft, originalTop);
		});

		header.addEventListener('pointermove', (e) => {
			if (!dragging) return;
			let x = originalLeft + (e.clientX - startX);
			let y = originalTop + (e.clientY - startY);
			const w = box.offsetWidth,
				h = box.offsetHeight;
			x = Math.min(Math.max(0, x), Math.max(0, window.innerWidth - w));
			y = Math.min(Math.max(0, y), Math.max(0, window.innerHeight - h));
			box.style.left = `${x}px`;
			box.style.top = `${y}px`;
		});

		function endDrag(e) {
			if (!dragging) return;
			dragging = false;
			try {
				header.releasePointerCapture(e.pointerId);
			} catch (err) {}
			log('drag: end');
		}
		header.addEventListener('pointerup', endDrag);
		header.addEventListener('pointercancel', endDrag);
	}

	log('init complete');
})();
