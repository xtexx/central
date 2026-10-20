<?php
namespace MediaWiki\Skins\Vector\Components;

use Countable;

/**
 * VectorComponentMenu component
 */
class VectorComponentMenu implements VectorComponent, Countable {
	public const COLLAPSIBLE_CLASS = 'vector-menu-item--collapsible';

	/**
	 * @param array $data menu data
	 * @param array $menuItemStyles all menu items will use default styles unless there's an item-specific override
	 * @param array $menuItemStyleOverrides styles for individual menu items keyed by item id
	 */
	public function __construct(
		private array $data,
		private array $menuItemStyles = [],
		private array $menuItemStyleOverrides = []
	) {
		$this->data += [
			'class' => '',
			'label' => '',
			'html-tooltip' => '',
			'label-class' => '',
			'html-before-portal' => '',
			'html-items' => '',
			'html-after-portal' => '',
			'array-list-items' => null,
		];

		$menuItemsData = $this->data['array-list-items'];
		if ( $this->data[ 'html-items' ] ) {
			// Using HTML string rendering
			$this->data[ 'array-list-items' ] = null;
		} elseif ( $menuItemsData ) {
			// Using template based rendering, update the menu item styles
			$this->data['array-list-items'] = $this->updateMenuItemStyles(
				$menuItemsData,
				$menuItemStyles,
				$menuItemStyleOverrides
			);
		}
	}

	/**
	 * Counts how many items the menu has.
	 */
	public function count(): int {
		$items = $this->data['array-list-items'] ?? null;
		if ( $items ) {
			return count( $items );
		}
		$htmlItems = $this->data['html-items'] ?? '';
		return substr_count( $htmlItems, '<li' );
	}

	/**
	 * Update menu item styling based of default menu styles and overrides
	 * Style options include: 'button', 'collapsible', 'icon', 'class'
	 * 'button' can be boolean or an array with button options, e.g. ['iconOnly' => true]
	 *
	 * @param array $menuItems
	 * @param array $menuItemStyles all menu items will use these styles unless there's an item specific override
	 * @param array $menuItemStyleOverrides styles for individual menu items keyed by item id.
	 *   A menu item can be removed if it is set to "false"
	 * @return array
	 */
	private static function updateMenuItemStyles( $menuItems, $menuItemStyles, $menuItemStyleOverrides ) {
		$menuItems = array_map( static function ( $item ) use ( $menuItemStyles, $menuItemStyleOverrides ) {
			$id = $item['id'];
			$hasOverrides = $id && isset( $menuItemStyleOverrides[ $id ] );
			$styles = $hasOverrides ? $menuItemStyleOverrides[ $id ] : $menuItemStyles;

			if ( $styles === false ) {
				return null;
			}

			$isCollapsible = $styles['collapsible'] ?? false;
			// collapsible class is added to the item (LI element) class
			if ( $isCollapsible ) {
				$class = $item['class'] ?? '';
				$item['class'] = $class . ' ' . self::COLLAPSIBLE_CLASS;
			}

			$customClass = $menuItemStyleOverrides[ $id ]['class'] ?? $menuItemStyles['class'] ?? '';
			if ( $customClass ) {
				$item['class'] = trim( $item['class'] . ' ' . $customClass );
			}

			// Update link classes
			$item['array-links'] = array_map( static function ( $link ) use ( $styles ) {
				// Override existing icon if needed
				$existingIcon = $link['icon'] ?? null;
				$icon = array_key_exists( 'icon', $styles ) ? $styles['icon'] : $existingIcon;

				$buttonStyles = $styles['button'] ?? false;
				if ( $buttonStyles ) {
					$attributes = array_column( $link['array-attributes'] ?? [], 'value', 'key' );
					$buttonComponent = new VectorComponentButton(
						label: $link['text'] ?? '',
						icon: $icon,
						id: $attributes['id'] ?? '',
						class: $attributes['class'] ?? '',
						attributes: $attributes,
						weight: 'quiet',
						action: $styles['button']['action'] ?? 'default',
						iconOnly: $styles['button']['iconOnly'] ?? false,
						href: $attributes['href'] ?? '',
					);
					return [
						'data-button' => $buttonComponent->getTemplateData()
					];
				}

				// TODO: Use VectorComponentLink instead of mutating link data directly
				$link['icon'] = $icon;
				return $link;
			}, $item['array-links'] ?? [] );
			return $item;
		}, $menuItems );
		return array_values(
			array_filter(
				$menuItems,
				static function ( $view ) {
					return $view !== null;
				}
			)
		);
	}

	/**
	 * @inheritDoc
	 */
	public function getTemplateData(): array {
		return $this->data;
	}
}
