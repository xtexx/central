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
$wgGroupPermissions['l-accessor'] = ['read' => true, 'autopatrol' => true, 'pagelang' => true];
$wgAddGroups['l-accessor'] = ['l-accessor'];
$wgGroupPermissions['sysop']['pagelang'] = true;

// Namespaces
const NS_L = 3000;
const NS_L_TALK = 3001;
$wgExtraNamespaces[NS_L] = 'L';
$wgExtraNamespaces[NS_L_TALK] = 'L讨论';
$wgContentNamespaces[] = NS_L;
xvSetAssocTrues('wgNamespacesWithSubpages', [NS_L, NS_L_TALK]);
xvMergeInto('wgNonincludableNamespaces', [NS_L, NS_L_TALK]);
$wgVisualEditorAvailableNamespaces['L'] = true;

// Lockdown
$wgNamespacePermissionLockdown[NS_L]['read'] = ['l-accessor'];
$wgNamespacePermissionLockdown[NS_L]['edit'] = ['l-accessor'];

require_once "$xvConfigDirectory/common/GlobalSettings.php";
