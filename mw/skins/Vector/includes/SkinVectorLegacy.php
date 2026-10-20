<?php

namespace MediaWiki\Skins\Vector;

use MediaWiki\Exception\MWException;
use MediaWiki\Language\LanguageConverterFactory;
use MediaWiki\Skin\Components\SkinComponentUtils;
use MediaWiki\Skin\SkinMustache;
use MediaWiki\Skin\SkinTemplate;
use MediaWiki\Skins\Vector\Components\VectorComponentSearchBox;
use MediaWiki\Skins\Vector\Components\VectorComponentVariants;

/**
 * @ingroup Skins
 * @package Vector
 * @internal
 */
class SkinVectorLegacy extends SkinMustache {
	/** @var int */
	private const MENU_TYPE_DEFAULT = 0;
	/** @var int */
	private const MENU_TYPE_TABS = 1;
	/** @var int */
	private const MENU_TYPE_DROPDOWN = 2;
	private const MENU_TYPE_PORTAL = 3;

	public function __construct(
		private readonly LanguageConverterFactory $languageConverterFactory,
		array $options
	) {
		parent::__construct( $options );
	}

	/**
	 * Adds class to a property
	 *
	 * @param array|string|bool &$item to update
	 * @param array|string $classes to add to the item
	 */
	private static function appendClassToItem( &$item, $classes ) {
		$existingClasses = $item;

		if ( is_array( $existingClasses ) ) {
			// Treat as array
			$newArrayClasses = is_array( $classes ) ? $classes : [ trim( $classes ) ];
			$item = array_merge( $existingClasses, $newArrayClasses );
		} elseif ( is_string( $existingClasses ) ) {
			// Treat as string
			$newStrClasses = is_string( $classes ) ? trim( $classes ) : implode( ' ', $classes );
			$item .= ' ' . $newStrClasses;
		} else {
			// Treat as whatever $classes is
			$item = $classes;
		}

		if ( is_string( $item ) ) {
			$item = trim( $item );
		}
	}

	/**
	 * Moves watch item from actions to views menu.
	 *
	 * @internal used inside Hooks::onSkinTemplateNavigation
	 * @param array &$content_navigation
	 */
	private static function updateActionsMenu( &$content_navigation ) {
		$key = null;
		if ( isset( $content_navigation['actions']['watch'] ) ) {
			$key = 'watch';
		}
		if ( isset( $content_navigation['actions']['unwatch'] ) ) {
			$key = 'unwatch';
		}

		// Promote watch link from actions to views and add an icon
		// The second check to isset is pointless but shuts up phan.
		if ( $key !== null && isset( $content_navigation['actions'][ $key ] ) ) {
			$content_navigation['views'][$key] = $content_navigation['actions'][$key];
			unset( $content_navigation['actions'][$key] );
		}
	}

	/**
	 * Update "views" menu items to support items in Legacy Vector. Only used by watchstar
	 *
	 * @internal used inside Hooks::onSkinTemplateNavigation
	 * @param array &$content_navigation
	 */
	private static function updateViewsMenuIconsLegacyVector( &$content_navigation ) {
		foreach ( $content_navigation['views'] as $key => &$item ) {
			$icon = $item['icon'] ?? null;
			$itemClass = $item['class'] ?? '';
			if ( $icon ) {
				self::appendClassToItem(
					$itemClass,
					[ 'icon' ]
				);
			}
			$item['class'] = $itemClass;
		}
	}

	/**
	 * Upgrades Vector's watch action to a watchstar.
	 * This is invoked inside SkinVector, not via skin registration, as skin hooks
	 * are not guaranteed to run last.
	 *
	 * @inheritDoc
	 */
	protected function runOnSkinTemplateNavigationHooks( SkinTemplate $skin, &$content_navigation ) {
		parent::runOnSkinTemplateNavigationHooks( $skin, $content_navigation );
		// For temp users, add createaccount right after user-page (before notifications)
		$createAccountItem = [];
		if ( $skin->getUser()->isTemp() ) {
			$returnto = SkinComponentUtils::getReturnToParam(
				$skin->getTitle(), $skin->getRequest(), $skin->getAuthority()
			);
			$createAccountItem['createaccount'] = $skin->buildCreateAccountData( $returnto );
		}
		$content_navigation['user-menu'] = array_merge(
			$content_navigation['user-interface-preferences'],
			$content_navigation['user-page'],
			$createAccountItem,
			$content_navigation['notifications'],
			$content_navigation['user-menu']
		);
		unset(
			$content_navigation['notifications'],
			$content_navigation['user-interface-preferences'],
			$content_navigation['user-page']
		);

		// Historically all special pages have a "Special pages" tab.
		// This is not supported by the associated-pages menu so we add it here
		// to retain classic behaviour.
		$title = $skin->getOutput()->getTitle();
		$associatedPages = $content_navigation['associated-pages'];
		if ( count( $associatedPages ) === 0 && !$title->canExist() ) {
			try {
				$url = $skin->getRequest()->getRequestURL();
			} catch ( MWException ) {
				$url = false;
			}
			$content_navigation['associated-pages'] = [
				'special' => [
					'class' => 'selected',
					'text' => $this->msg( 'nstab-special' )->text(),
					'href' => $url,
					'context' => 'subject',
				]
			] + $associatedPages;
		}
		$relevantTitle = $skin->getRelevantTitle();
		if (
			$skin->getConfig()->get( 'VectorUseIconWatch' ) &&
			$relevantTitle && $relevantTitle->canExist()
		) {
			self::updateActionsMenu( $content_navigation );
		}
		// The updating of the views menu happens /after/ the overflow menu has been created
		// this avoids icons showing in the more overflow menu.
		self::updateViewsMenuIconsLegacyVector( $content_navigation );
	}

	/**
	 * Performs updates to all portlets.
	 *
	 * @param array $data
	 * @return array
	 */
	private function decoratePortletsData( array $data ) {
		foreach ( $data['data-portlets'] as $key => $pData ) {
			$data['data-portlets'][$key] = $this->decoratePortletData(
				$key,
				$pData
			);
		}
		$mainMenuData = $data['data-portlets-sidebar'];
		$mainMenuData['data-portlets-first'] = $this->decoratePortletData(
			'navigation', $mainMenuData['data-portlets-first']
		);
		$rest = $mainMenuData['array-portlets-rest'];
		foreach ( $rest as $key => $pData ) {
			$rest[$key] = $this->decoratePortletData(
				$pData['id'], $pData
			);
		}
		$mainMenuData['array-portlets-rest'] = $rest;
		$data['data-portlets-main-menu'] = $mainMenuData;
		return $data;
	}

	/**
	 * Performs the following updates to portlet data:
	 * - Adds concept of menu types
	 * - Marks the selected variant in the variant portlet
	 * - modifies tooltips of personal and user-menu portlets
	 * @param string $key
	 * @param array $portletData
	 * @return array
	 */
	private function decoratePortletData(
		string $key,
		array $portletData
	): array {
		$isIconDropdown = false;
		switch ( $key ) {
			case 'data-actions':
			case 'data-variants':
			case 'data-sticky-header-toc':
				$type = self::MENU_TYPE_DROPDOWN;
				break;
			case 'data-views':
			case 'data-associated-pages':
				$type = self::MENU_TYPE_TABS;
				break;
			case 'data-user-menu':
				$type = self::MENU_TYPE_DEFAULT;
				// Set tooltip to empty string for the personal menu for both logged-in and logged-out users
				// to avoid showing the tooltip for legacy version.
				$portletData['html-tooltip'] = '';
				$portletData['class'] .= ' vector-user-menu-legacy';
				break;
			case 'data-footer-icons':
				$portletData['class'] .= ' noprint';
				// Fall through to return portlet data without menu type classes.
			case 'data-footer-info':
			case 'data-footer-places':
				return $portletData;
			default:
				$type = self::MENU_TYPE_PORTAL;
				break;
		}

		// Special casing for Variant to change label to selected.
		// Hopefully we can revisit and possibly remove this code when the language switcher is moved.
		if ( $key === 'data-variants' ) {
			$variant = new VectorComponentVariants(
				$this->languageConverterFactory,
				$portletData,
				$this->getTitle()->getPageLanguage(),
				$this->msg( 'vector-language-variant-switcher-label' )->text()
			);
			$portletData[ 'label' ] = $variant->getTemplateData()[ 'data-variants-dropdown' ][ 'label' ];
		}

		$portletData = $this->updatePortletClasses(
			$portletData,
			$type
		);

		return $portletData + [
			'is-dropdown' => $type === self::MENU_TYPE_DROPDOWN,
			'is-portal' => $type === self::MENU_TYPE_PORTAL,
		];
	}

	/**
	 * Helper for applying Vector menu classes to portlets
	 *
	 * @param array $portletData returned by SkinMustache to decorate
	 * @param int $type representing one of the menu types (see MENU_TYPE_* constants)
	 * @return array modified version of portletData input
	 */
	private function updatePortletClasses(
		array $portletData,
		int $type = self::MENU_TYPE_DEFAULT
	) {
		$extraClasses = [
			self::MENU_TYPE_DROPDOWN => 'vector-menu-dropdown',
			self::MENU_TYPE_TABS => 'vector-menu-tabs vector-menu-tabs-legacy',
			self::MENU_TYPE_PORTAL => 'vector-menu-portal portal',
			self::MENU_TYPE_DEFAULT => '',
		];
		$portletData['class'] .= ' ' . $extraClasses[$type];

		if ( !isset( $portletData['heading-class'] ) ) {
			$portletData['heading-class'] = '';
		}

		$portletData['class'] = trim( $portletData['class'] );
		$portletData['heading-class'] = trim( $portletData['heading-class'] );
		return $portletData;
	}

	/**
	 * @inheritDoc
	 */
	public function getTemplateData(): array {
		$parentData = $this->decoratePortletsData( parent::getTemplateData() );

		$components = [
			'data-search-box' => new VectorComponentSearchBox(
				$parentData['data-search-box'],
				false,
				// is primary mode of search
				true,
				'searchform',
				true,
				$this->getConfig(),
				Constants::SEARCH_BOX_INPUT_LOCATION_DEFAULT,
				$this->getContext()
			),
		];
		foreach ( $components as $key => $component ) {
			$parentData[$key] = $component->getTemplateData();
		}

		// SkinVector sometimes serves new Vector as part of removing the
		// skin version user preference. To avoid T302461 we need to unset it here.
		// This shouldn't be run on SkinVector22.
		unset( $parentData['data-toc'] );
		return $parentData;
	}
}
