<?php
namespace MediaWiki\Skins\Vector\Components;

use MediaWiki\Language\MessageLocalizer;

/**
 * VectorComponentPinnableHeader component
 */
class VectorComponentPinnableHeader implements VectorComponent {
	/**
	 * @param MessageLocalizer $localizer
	 * @param bool $pinned
	 * @param string $id Pinnable element id, by convention this should include the `vector-`
	 * prefix e.g. `vector-page-tools` or `vector-toc`.
	 * @param string $featureName Pinned and unpinned states will
	 * persist for logged-in users by leveraging features.js to manage the user
	 * preference storage and the toggling of the body class. This name should NOT
	 * contain the "vector-" prefix.
	 * @param string $unpinAriaLabel i18n message key for the aria-label on the unpin (hide) button.
	 * @param string $pinAriaLabel i18n message key for the aria-label on the pin (move to sidebar) button.
	 * @param string|null $labelTagName Element type of the label. Either a 'div' or a 'h2'
	 *   in the case of the pinnable ToC.
	 */
	public function __construct(
		private readonly MessageLocalizer $localizer,
		private readonly bool $pinned,
		private readonly string $id,
		private readonly string $featureName,
		private readonly string $unpinAriaLabel,
		private readonly string $pinAriaLabel,
		private readonly ?string $labelTagName = 'div',
	) {
	}

	/**
	 * @inheritDoc
	 */
	public function getTemplateData(): array {
		$messageLocalizer = $this->localizer;
		$data = [
			'is-pinned' => $this->pinned,
			'label' => $messageLocalizer->msg( $this->id . '-label' )->text(),
			'label-tag-name' => $this->labelTagName,
			'pin-label' => $messageLocalizer->msg( 'vector-pin-element-label' )->text(),
			'unpin-label' => $messageLocalizer->msg( 'vector-unpin-element-label' )->text(),
			'pin-aria-label' => $messageLocalizer->msg(
				$this->pinAriaLabel,
				$messageLocalizer->msg( $this->id . '-label' )->text()
			)->text(),
			'unpin-aria-label' => $messageLocalizer->msg(
				$this->unpinAriaLabel,
				$messageLocalizer->msg( $this->id . '-label' )->text()
			)->text(),
			'data-pinnable-element-id' => $this->id,
			'data-feature-name' => $this->featureName,
			// Assumes consistent naming standard for pinnable elements and their containers
			'data-unpinned-container-id' => $this->id . '-unpinned-container',
			'data-pinned-container-id' => $this->id . '-pinned-container'
		];
		return $data;
	}
}
