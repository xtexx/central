<?php
$wgSitename = "无名书架";
$wgMetaNamespace = "Unnamed Shelf";

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
const NS_SIDE = 3000;
const NS_SIDE_TALK = 3001;
$wgExtraNamespaces[NS_SIDE] = 'Side';
$wgExtraNamespaces[NS_SIDE_TALK] = 'Side讨论';
$wgContentNamespaces[] = NS_SIDE;
xvSetAssocTrues('wgNamespacesWithSubpages', [NS_SIDE, NS_SIDE_TALK]);
xvMergeInto('wgNonincludableNamespaces', [NS_SIDE, NS_SIDE_TALK]);
$wgVisualEditorAvailableNamespaces['Side'] = true;

$wgNamespaceAliases['US'] = NS_PROJECT;
$wgNamespaceAliases['Shelf'] = NS_PROJECT;
$wgNamespaceAliases['UST'] = NS_PROJECT_TALK;
$wgNamespaceAliases['US_talk'] = NS_PROJECT_TALK;
$wgNamespaceAliases['Shelf_talk'] = NS_PROJECT_TALK;

// Lockdown
$wgNamespacePermissionLockdown[NS_SIDE]['read'] = ['cache-fetcher', 'sysop'];
$wgNamespacePermissionLockdown[NS_SIDE]['edit'] = ['cache-fetcher', 'sysop'];

require_once "$xvConfigDirectory/common/GlobalSettings.php";
