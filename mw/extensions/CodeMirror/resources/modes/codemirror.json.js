const { jsonLanguage, jsonLinter } = require( '../lib/codemirror.bundle.modes.js' );
const CodeMirrorMode = require( './codemirror.mode.js' );

/**
 * JSON language support for CodeMirror.
 *
 * @example
 * const require = await mw.loader.using( [ 'ext.CodeMirror', 'ext.CodeMirror.modes' ] );
 * const CodeMirror = require( 'ext.CodeMirror' );
 * const { json } = require( 'ext.CodeMirror.modes' );
 * const cm = new CodeMirror( myTextarea, json() );
 * cm.initialize();
 * @extends CodeMirrorMode
 * @hideconstructor
 */
class CodeMirrorJson extends CodeMirrorMode {

	/** @inheritDoc */
	get language() {
		return jsonLanguage;
	}

	/** @inheritDoc */
	get lintSource() {
		return jsonLinter;
	}

	/** @inheritDoc */
	get hasWorker() {
		// JSON linting is done in the main thread.
		return false;
	}
}

module.exports = CodeMirrorJson;
