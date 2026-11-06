// ==UserScript==
// @name         FiF Challenge Skipper
// @namespace    https://xtexx.eu.org/
// @version      1.0.0
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
	const INTERVAL_MS = 700;
	const MIN_RECORD_TIME_SEC = 5;
	const STOP_RECORD_PROBABILITY = 0.2;

	const log = (...a) => DEBUG && console.log('[fif-fast-skip]', ...a);
	const warn = (...a) => DEBUG && console.warn('[fif-fast-skip]', ...a);
	const info = (...a) => DEBUG && console.info('[fif-fast-skip]', ...a);

	let recordBeginTime = null;

	setInterval(function () {
		// Skip playing voices
		const skipPlayBtn = document.querySelector(
			'div.exercise_wrap div.service-item-taste div.btn-content img.btn-skip'
		);
		if (skipPlayBtn && skipPlayBtn.checkVisibility()) {
			info('Skip playing button visible, skipping');
			skipPlayBtn.dispatchEvent(
				new Event('click', { bubbles: true, cancelable: true })
			);
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
				stopRecordBtn.dispatchEvent(
					new Event('click', { bubbles: true, cancelable: true })
				);
			}
		} else {
			recordBeginTime = null;
		}
	}, INTERVAL_MS);

	info('FiF skipper ready');
})();
