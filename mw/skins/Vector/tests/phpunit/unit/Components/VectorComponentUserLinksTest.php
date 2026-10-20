<?php
/**
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * http://www.gnu.org/copyleft/gpl.html
 *
 * @file
 * @since 1.35
 */

namespace MediaWiki\Skins\Vector\Tests\Unit\Components;

use MediaWiki\Language\MessageLocalizer;
use MediaWiki\Message\Message;
use MediaWiki\Skins\Vector\Components\VectorComponentUserLinks;
use MediaWiki\User\UserIdentity;
use MediaWiki\User\UserNameUtils;

/**
 * @group Vector
 * @group Components
 * @coversDefaultClass \MediaWiki\Skins\Vector\Components\VectorComponentUserLinks
 */
class VectorComponentUserLinksTest extends VectorComponentSnapshotTestCase {
	private const ICON = 'testAvatar';
	private const ULS_LINK = [
		'icon' => 'wikimedia-language',
		'array-attributes' => [
			[
				'key' => 'href',
				'value' => '#',
			],
			[
				'key' => 'class',
				'value' => 'uls',
			]
		],
		'text' => 'English',
	];
	private const LOGIN_LINK = [
		'icon' => 'user',
		'array-attributes' => [
			[
				'key' => 'href',
				'value' => '/login',
			],
			[
				'key' => 'class',
				'value' => '',
			]
		],
		'text' => 'Login',
	];
	private const LOGIN_LINK_NO_ICON = [
		'icon' => null,
		'array-attributes' => [
			[
				'key' => 'href',
				'value' => '/login',
			],
			[
				'key' => 'class',
				'value' => '',
			]
		],
		'text' => 'Login',
	];
	private const DONATE_LINK = [
		'icon' => 'heart',
		'array-attributes' => [
			[
				'key' => 'href',
				'value' => '/donate',
			],
			[
				'key' => 'class',
				'value' => '',
			]
		],
		'text' => 'Donate',
	];
	private const WATCHLIST_LINK = [
		'icon' => 'watchlist',
		'class' => '',
		'array-attributes' => [
			[
				'key' => 'href',
				'value' => '/watchlist',
			],
			[
				'key' => 'class',
				'value' => '',
			]
		],
		'text' => 'Watchlist',
	];
	private const ULS_ITEM = [
		'html-item' => 'ignore',
		'name' => 'uls',
		'html' => 'English',
		'id' => 'ca-uls',
		'class' => 'mw-list-item',
		'array-links' => [
			self::ULS_LINK,
		],
	];
	private const LOGIN_ITEM = [
		'html-item' => 'ignore',
		'name' => 'login',
		'html' => 'Login',
		'id' => 'pt-login',
		'class' => 'mw-list-item',
		'array-links' => [
			self::LOGIN_LINK,
		],
	];
	private const DONATE_ITEM = [
		'html-item' => 'ignore',
		'name' => 'donate',
		'html' => 'Donate',
		'id' => 'pt-sitesupport',
		'class' => '',
		'array-links' => [
			self::DONATE_LINK,
		],
	];
	private const WATCHLIST_ITEM = [
		'html-item' => 'ignore',
		'name' => 'watchlist',
		'html' => 'Watchlist',
		'id' => 'pt-watchlist',
		'class' => '',
		'array-links' => [
			self::WATCHLIST_LINK,
		],
	];

	private static function helperMakePortletData( $items = [] ) {
		return [
			'class'	=> '',
			'array-items' => $items,
		];
	}

	/**
	 * @covers ::getTemplateData
	 */
	public function testGetTemplateDataPreservesUserMenuTooltip() {
		$localizer = $this->createMock( MessageLocalizer::class );
		$userMock = $this->createMock( UserIdentity::class );
		$userMock->method( 'isRegistered' )->willReturn( false );
		$userNameUtilsMock = $this->createMock( UserNameUtils::class );
		$localizer->method( 'msg' )->willReturnCallback( function ( $key, ...$params ) {
			$msg = $this->createMock( Message::class );
			$msg->method( '__toString' )->willReturn( $key );
			$msg->method( 'escaped' )->willReturn( $key );
			$msg->method( 'rawParams' )->willReturnSelf();
			$msg->method( 'text' )->willReturn( $key );
			return $msg;
		} );

		$userLinks = new VectorComponentUserLinks(
			$localizer,
			$userMock,
			$userNameUtilsMock,
			[
				'data-user-menu' => [
					'class' => '',
					'array-items' => [],
					'html-tooltip' => ' title="User Menu"',
				],
				'data-user-interface-preferences' => self::helperMakePortletData( [] ),
			],
			self::ICON
		);

		$this->assertSame(
			' title="User Menu"',
			$userLinks->getTemplateData()['data-user-links-menus'][0]['html-tooltip']
		);
	}

	public static function provideGetData() {
		return [
			"When zero links" => [
				// anonymous user
				false,
				[
					'data-user-menu' => self::helperMakePortletData( [] ),
					'data-user-interface-preferences' => self::helperMakePortletData( [] ),
				],
				'userlinks-zero.json',
			],
			"Overflow links" => [
				// anonymous user
				false,
				[
					'data-user-menu' => self::helperMakePortletData( [
						self::DONATE_ITEM,
						self::LOGIN_ITEM,
					] ),
					'data-user-interface-preferences' => self::helperMakePortletData( [] ),
				],
				'userlinks-overflow.json',
			],
			"User interface preferences" => [
				// anonymous user
				false,
				[
					'data-user-menu' => self::helperMakePortletData( [] ),
					'data-user-interface-preferences' => self::helperMakePortletData( [ self::ULS_ITEM ] ),
				],
				'userlinks-preferences.json',
			],
			"Loggedin user" => [
				true,
				[
					'data-user-menu' => self::helperMakePortletData( [
						self::WATCHLIST_ITEM
					] ),
					'data-user-interface-preferences' => self::helperMakePortletData( [] ),
				],
				'userlinks-loggedin.json'
			]
		];
	}

	/**
	 * @covers ::getTemplateData
	 * @dataProvider provideGetData
	 */
	public function testGetTemplateData(
		bool $isRegistered,
		array $portletData,
		string $expectedSnapshot
	) {
		$localizer = $this->createMock( MessageLocalizer::class );
		$userMock = $this->createMock( UserIdentity::class );
		$userMock->method( 'isRegistered' )->willReturn( $isRegistered );
		$userNameUtilsMock = $this->createMock( UserNameUtils::class );
		$localizer->method( 'msg' )->willReturnCallback( function ( $key, ...$params ) {
			$msg = $this->createMock( Message::class );
			$msg->method( '__toString' )->willReturn( $key );
			$msg->method( 'escaped' )->willReturn( $key );
			$msg->method( 'rawParams' )->willReturnSelf();
			$msg->method( 'text' )->willReturn( $key );
			return $msg;
		} );

		$userLinks = new VectorComponentUserLinks(
			$localizer,
			$userMock,
			$userNameUtilsMock,
			$portletData,
			self::ICON
		);
		$this->assertEqualsSnapshot(
			$expectedSnapshot,
			$userLinks->getTemplateData()
		);
	}
}
