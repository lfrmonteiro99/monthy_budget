import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../theme/app_colors.dart';

/// Chat message bubble with asymmetric corner geometry and optional avatar.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.isUser,
    required this.showAvatar,
    required this.child,
  });

  final bool isUser;
  final bool showAvatar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth * 0.78;
    final bubbleColor = isUser
        ? AppColors.ink(context)
        : AppColors.bgSunk(context);
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      // Single Container per bubble — asymmetric corner geometry per spec
      // cannot be expressed via theme-driven CalmCard.
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
        ),
        child: child,
      ),
    );

    if (!showAvatar) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 4,
            left: isUser ? 0 : 36, // align below the AI avatar column
            right: isUser ? 36 : 0,
          ),
          child: bubble,
        ),
      );
    }

    final avatar = _BubbleAvatar(isUser: isUser);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[avatar, const SizedBox(width: 8)],
          Flexible(child: bubble),
          if (isUser) ...[const SizedBox(width: 8), avatar],
        ],
      ),
    );
  }
}

/// 28×28 round avatar — coach uses `CalmAvatarBadge`-equivalent ink fill
/// with Fraunces "C". User mirrors with `userInitials` ink50 outline ink20.
class _BubbleAvatar extends StatelessWidget {
  const _BubbleAvatar({required this.isUser});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    if (!isUser) {
      // Coach avatar: ink fill, bg-coloured "C" in Fraunces 14.
      return CalmAvatarBadge(initials: 'C', size: 28);
    }
    // User avatar: outline ink20, ink50 initial. No fill — visually distinct.
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(color: AppColors.ink20(context)),
          ),
        ),
        child: Center(
          child: Text(
            'U',
            // TODO(l10n): swap "U" for personalInfo.userInitials when available.
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink50(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bubble text body. AI uses Markdown (with inline accent CTA pills allowed
/// via prose), user uses plain selectable text reversed on ink.
class MessageBody extends StatelessWidget {
  const MessageBody({super.key, required this.content, required this.isUser});

  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final textColor = isUser ? AppColors.bg(context) : AppColors.ink(context);
    if (isUser) {
      return SelectableText(
        content,
        style: TextStyle(fontSize: 14, color: textColor, height: 1.45),
      );
    }
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 14, color: textColor, height: 1.45),
        strong: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
        listBullet: TextStyle(fontSize: 14, color: textColor, height: 1.45),
        h1: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        h2: TextStyle(
          fontSize: 15,
          color: textColor,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}
