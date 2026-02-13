import { Context, Telegraf } from 'telegraf';
import { ExtraReplyMessage } from 'telegraf/typings/telegram-types';

import { VercelRequest, VercelResponse } from '@vercel/node';
import { development, production } from './core';
import { name, version, author } from '../package.json';
import { ChatMember, ChatPermissions } from 'telegraf/typings/core/types/typegram';

const BOT_TOKEN = process.env.BOT_TOKEN || '';
const CMD_SUFFIX = process.env.CMD_SUFFIX || '';
const ENVIRONMENT = process.env.NODE_ENV || '';

const bot = new Telegraf(BOT_TOKEN);

async function replyTo(
	ctx: Context,
	message: string,
	extra?: ExtraReplyMessage,
) {
	const messageId = ctx.message?.message_id;
	if (messageId == null) {
		throw new Error('message_id is null');
	}
	await ctx.reply(message, {
		reply_parameters: { message_id: messageId },
		...extra,
	});
}

function isUserRealAdmin(defaultPerms: ChatPermissions, user: ChatMember): boolean {
	if (user.status == 'creator') return true;
	if (user.status == 'administrator') {
		for (let k in user) {
			if (k == 'can_manage_chat') continue;
			if ((user as any)[k] === true) {
				if((k in defaultPerms) && (defaultPerms as any)[k] === true) continue;
				return true;
			}
		}
	}
	return false;
}

bot.command(['help', 'start'], async (ctx) => {
	const message = `${name} ${version}\n${author}\nSee https://codeberg.org/xtex/telegram-title-bot for more details.`;
	await ctx.reply(message);
});

bot.catch(async (err, ctx) => {
	await replyTo(ctx, `Error: ${err}`);
	throw err;
});

bot.command([`t${CMD_SUFFIX}`, `title${CMD_SUFFIX}`], async (ctx) => {
	if (ctx.chat.type != 'group' && ctx.chat.type != 'supergroup')
		return await replyTo(ctx, 'This message can only be used in groups.');
	const title = ctx.args[0] ?? null;
	if (title == null) return await replyTo(ctx, 'Usage: /t <YOUR TITLE>');

	let member = await ctx.getChatMember(ctx.message.from.id);
	if (['member', 'creator', 'administrator'].includes(member.status)) {
		if (member.status == 'member') {
			const chatInfo = await ctx.getChat();
			if (chatInfo.type != 'group' && chatInfo.type != 'supergroup')
				throw 'Inconsistent group type';
			const chatPermissions = chatInfo.permissions;
			if (chatPermissions == null)
				throw 'Chat permission must be available in getChat';
			await ctx.promoteChatMember(member.user.id, {
				is_anonymous: false,
				can_manage_chat: true,
				can_delete_messages: false,
				can_manage_video_chats: false,
				can_restrict_members: false,
				can_promote_members: false,
				can_change_info: chatPermissions.can_change_info || false,
				can_invite_users: chatPermissions.can_invite_users || false,
				can_post_stories: false,
				can_edit_stories: false,
				can_delete_stories: false,
				can_pin_messages: chatPermissions.can_pin_messages || false,
				can_manage_topics: chatPermissions.can_manage_topics || false,
			});
			await replyTo(ctx, 'Promoted to administrator');
		}
		await ctx.setChatAdministratorCustomTitle(member.user.id, title);
		await replyTo(ctx, `Title set: \`${title}\``, {
			parse_mode: 'MarkdownV2',
		});
	} else await replyTo(ctx, `Bad membership status: ${member.status}`);
});

bot.command([`detitle${CMD_SUFFIX}`, `untitle${CMD_SUFFIX}`], async (ctx) => {
	if (ctx.chat.type != 'group' && ctx.chat.type != 'supergroup')
		return await replyTo(ctx, 'This message can only be used in groups.');

	const chatInfo = await ctx.getChat();
	if (chatInfo.type != 'group' && chatInfo.type != 'supergroup')
		throw 'Inconsistent group type';
	const chatPermissions = chatInfo.permissions;
	if (chatPermissions == null)
		throw 'Chat permission must be available in getChat';

	let sender = await ctx.getChatMember(ctx.message.from.id);
	if (!isUserRealAdmin(chatPermissions, sender))
		return await replyTo(ctx, 'Only administrators can do');

	const target = ctx.args[0] ?? null;
	let targetUser: ChatMember;
	if (target == null) {
		const replyTarget = ctx.message.reply_to_message?.from?.id;
		targetUser = await ctx.getChatMember(
			replyTarget ?? ctx.message.from.id,
		);
	} else {
		try {
			targetUser = await ctx.getChatMember(parseInt(target));
		} catch {
			return await replyTo(ctx, 'Invalid user ID');
		}
	}

	if (targetUser.status == 'administrator') {
		if (isUserRealAdmin(chatPermissions, targetUser))
			return await replyTo(
				ctx,
				'Cannot be used against real administrators',
			);

		await ctx.promoteChatMember(targetUser.user.id, {
			is_anonymous: false,
			can_manage_chat: false,
			can_delete_messages: false,
			can_manage_video_chats: false,
			can_restrict_members: false,
			can_promote_members: false,
			can_change_info: false,
			can_invite_users: false,
			can_post_stories: false,
			can_edit_stories: false,
			can_delete_stories: false,
			can_pin_messages: false,
			can_manage_topics: false,
		});
		await replyTo(ctx, 'Demoted user');
	} else await replyTo(ctx, `Bad membership status: ${targetUser.status}`);
});

export const startVercel = async (req: VercelRequest, res: VercelResponse) => {
	await production(req, res, bot);
};
ENVIRONMENT !== 'production' && development(bot);
