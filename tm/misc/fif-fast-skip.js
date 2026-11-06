// ==UserScript==
// @name         FiF Challenge Skipper
// @namespace    https://xtexx.eu.org/
// @version      1.0.1
// @description  Skips FiF examination as fast as possible
// @author       xtex
// @match        *://*.fifedu.com/*
// @run-at       document-start
// @grant        none
// @supportURL   https://codeberg.org/xtex/gadgets/issues
// @downloadURL  https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/fif-fast-skip.js
// @updateURL    https://codeberg.org/xtex/gadgets/raw/branch/stable/tm/misc/fif-fast-skip.js
// @license      Unlicense
// ==/UserScript==

(function () {
	'use strict';

	const DEBUG = true;
	const INTERVAL_MS = 900;
	const DELAY_MS = 400;
	const MIN_RECORD_TIME_SEC = 5;
	const STOP_RECORD_PROBABILITY = 0.2;

	const log = (...a) => DEBUG && console.log('[fif-fast-skip]', ...a);
	const warn = (...a) => DEBUG && console.warn('[fif-fast-skip]', ...a);
	const info = (...a) => DEBUG && console.info('[fif-fast-skip]', ...a);

	let recordBeginTime = null;

	function clickBtn(btn) {
		info('Click button', btn);
		btn.dispatchEvent(
			new Event('click', { bubbles: true, cancelable: true })
		);
	}

	setInterval(function () {
		// Close "音频不存在, 是否继续?" message box
		let noSkipPlay = false;
		for (const msgBox of document.querySelectorAll('.el-message-box')) {
			if (!msgBox.checkVisibility()) continue;
			const msgTextEl = msgBox.querySelector('.el-message-box__message');
			const msgText = msgTextEl ? msgTextEl.textContent : '';
			info('Found message box', msgText);
			if (msgText.trim().indexOf('音频不存在, 是否继续?') >= 0) {
				info('Matched audio not found message box');
				const primaryBtn = msgBox.querySelector('.el-button--primary');
				if (primaryBtn && primaryBtn.checkVisibility()) {
					info('Found primary continue button, clicking');
					setTimeout(clickBtn.bind(this, primaryBtn), DELAY_MS);
					noSkipPlay = true;
				}
			}
		}

		if (noSkipPlay) return;

		// Skip playing voices
		const skipPlayBtn = document.querySelector(
			'div.exercise_wrap div.service-item-taste div.btn-content img.btn-skip'
		);
		if (skipPlayBtn && skipPlayBtn.checkVisibility()) {
			info('Skip playing button visible');
			setTimeout(clickBtn.bind(this, skipPlayBtn), DELAY_MS);
		}

		// Stop recording automatically
		const stopRecordBtn = document.querySelector(
			'div#app div.exercise_main div.service-item-content button.taste-button.ready-button.ing'
		);
		if (stopRecordBtn && stopRecordBtn.checkVisibility()) {
			info('Stop recording button visible');
			const timeLabel = document.querySelector(
				'div#app div.exercise_main div.service-item-content div.time-box span.total-time em'
			);
			const timeSecs = timeLabel
				? Number.parseInt(timeLabel.textContent)
				: null;
			if (recordBeginTime === null) recordBeginTime = timeSecs;
			const elapsedTime = recordBeginTime
				? recordBeginTime - timeSecs
				: 0;
			info(`Recording time: ${timeSecs}/${recordBeginTime}`);
			info(`Elapsed time: ${elapsedTime}`);
			if (
				elapsedTime > MIN_RECORD_TIME_SEC &&
				Math.random() < STOP_RECORD_PROBABILITY
			) {
				info(`Stop recording`);
				setTimeout(clickBtn.bind(this, stopRecordBtn), DELAY_MS);
			}
		} else {
			recordBeginTime = null;
		}
	}, INTERVAL_MS);

	info('FiF skipper ready');
})();
