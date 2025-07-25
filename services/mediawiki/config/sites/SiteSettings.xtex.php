<?php
$wgSitename = "语义之瓶";
$wgMetaNamespace = "Bottle";

$xvTesting = true;
$xvCentralized = true;
$xvUseSelfHostedImages = true;
$wgPageLanguageUseDB = true;

$xvUseLockdown = true;
$xvUseTabberNeue = true;
$xvUseCargo = true;

require_once "$xvConfigDirectory/common/LoadExtensions.php";

$wgLanguageCode = 'zh';
$wgLocaltimezone = 'Asia/Shanghai';

$wgRightsUrl = "https://creativecommons.org/licenses/by-sa/4.0/";
$wgRightsText = "CC BY-SA 4.0";
$wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-sa.png";

xvLoadSkin('Lakeus');
$wgDefaultSkin = $wgDefaultMobileSkin = 'lakeus';

$xvUseEmailConfirmed = true;
$wgUsersNotifiedOnAllChanges = ['Xtex'];

// User rights
$xvRequireEmailConfirmedToEdit = true;
$wgGroupPermissions['cache-fetcher'] = ['read' => true, 'autopatrol' => true, 'pagelang' => true];
$wgAddGroups['cache-fetcher'] = ['cache-fetcher'];
$wgGroupPermissions['sysop']['pagelang'] = true;

// Namespaces
const NS_CACHE = 3000;
const NS_CACHE_TALK = 3001;
$wgExtraNamespaces[NS_CACHE] = 'Cache';
$wgExtraNamespaces[NS_CACHE_TALK] = 'Cache讨论';
$wgContentNamespaces[] = NS_CACHE;
xvSetAssocTrues('wgNamespacesWithSubpages', [NS_CACHE, NS_CACHE_TALK]);
xvMergeInto('wgNonincludableNamespaces', [NS_CACHE, NS_CACHE_TALK]);
$wgVisualEditorAvailableNamespaces['Cache'] = true;

// Lockdown
$wgNamespacePermissionLockdown[NS_CACHE]['read'] = ['cache-fetcher', 'sysop'];
$wgNamespacePermissionLockdown[NS_CACHE]['edit'] = ['cache-fetcher', 'sysop'];

require_once "$xvConfigDirectory/common/GlobalSettings.php";
