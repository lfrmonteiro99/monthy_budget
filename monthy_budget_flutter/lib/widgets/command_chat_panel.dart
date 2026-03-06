import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/command_action.dart';
import '../theme/app_colors.dart';

class CommandChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final bool isError;
  final bool isSuccess;

  const CommandChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
    this.isSuccess = false,
  });
}

class CommandChatPanel extends StatefulWidget {
  final VoidCallback onMinimize;
  final Future<CommandAction> Function(String input) onSendCommand;
  final Future<CommandResult> Function(CommandAction action) onExecuteAction;
  final void Function(String input, String action, Map<String, dynamic> params)
      onCachePattern;

  const CommandChatPanel({
    super.key,
    required this.onMinimize,
    required this.onSendCommand,
    required this.onExecuteAction,
    required this.onCachePattern,
  });

  @override
  State<CommandChatPanel> createState() => _CommandChatPanelState();
}

class _CommandChatPanelState extends State<CommandChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <CommandChatMessage>[];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final input = text.trim();
    if (input.isEmpty || _loading) return;
    _controller.clear();

    setState(() {
      _messages.add(CommandChatMessage(role: 'user', content: input));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final parsed = await widget.onSendCommand(input);

      if (!parsed.hasAction) {
        setState(() {
          _messages.add(CommandChatMessage(
            role: 'assistant',
            content: parsed.message.isNotEmpty
                ? parsed.message
                : S.of(context).cmdNotUnderstood,
          ));
        });
      } else {
        final result = await widget.onExecuteAction(parsed);
        if (result.succeeded) {
          setState(() {
            _messages.add(CommandChatMessage(
              role: 'assistant',
              content: parsed.message.isNotEmpty
                  ? parsed.message
                  : result.message,
              isSuccess: true,
            ));
          });
          widget.onCachePattern(input, parsed.action!, parsed.params ?? {});
        } else {
          setState(() {
            _messages.add(CommandChatMessage(
              role: 'assistant',
              content: S.of(context).cmdExecutionFailed,
              isError: true,
            ));
          });
        }
      }
    } catch (_) {
      setState(() {
        _messages.add(CommandChatMessage(
          role: 'assistant',
          content: S.of(context).cmdNotUnderstood,
          isError: true,
        ));
      });
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _applyTemplate(String template, {bool immediate = false}) {
    if (immediate) {
      _send(template);
      return;
    }
    _controller.text = template;
    final bracketIdx = template.indexOf('[');
    if (bracketIdx >= 0) {
      final endIdx = template.indexOf(']', bracketIdx);
      _controller.selection = TextSelection(
        baseOffset: bracketIdx,
        extentOffset: endIdx + 1,
      );
    } else {
      _controller.selection = TextSelection.collapsed(
        offset: template.length,
      );
    }
  }

  List<({String label, String example, bool immediate})> _capabilities(S l10n) {
    return [
      (
        label: l10n.cmdCapabilityAddExpense,
        example: l10n.cmdCapabilityAddExpenseExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityAddShoppingItem,
        example: l10n.cmdCapabilityAddShoppingItemExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityRemoveShoppingItem,
        example: l10n.cmdCapabilityRemoveShoppingItemExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityToggleShoppingItemChecked,
        example: l10n.cmdCapabilityToggleShoppingItemCheckedExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityAddSavingsGoal,
        example: l10n.cmdCapabilityAddSavingsGoalExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityAddSavingsContribution,
        example: l10n.cmdCapabilityAddSavingsContributionExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityAddRecurringExpense,
        example: l10n.cmdCapabilityAddRecurringExpenseExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityDeleteExpense,
        example: l10n.cmdCapabilityDeleteExpenseExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityChangeTheme,
        example: l10n.cmdCapabilityChangeThemeExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityChangePalette,
        example: l10n.cmdCapabilityChangePaletteExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityChangeLanguage,
        example: l10n.cmdCapabilityChangeLanguageExample,
        immediate: false,
      ),
      (
        label: l10n.cmdCapabilityNavigate,
        example: l10n.cmdCapabilityNavigateExample,
        immediate: true,
      ),
      (
        label: l10n.cmdCapabilityClearChecked,
        example: l10n.cmdCapabilityClearCheckedExample,
        immediate: true,
      ),
    ];
  }

  void _showCapabilitiesSheet(S l10n) {
    final capabilities = _capabilities(l10n);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cmdCapabilitiesTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.cmdCapabilitiesSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: capabilities.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: AppColors.border(context),
                    ),
                    itemBuilder: (context, index) {
                      final item = capabilities[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.example,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                        trailing: Icon(
                          item.immediate
                              ? Icons.rocket_launch_outlined
                              : Icons.edit_outlined,
                          size: 18,
                          color: AppColors.textMuted(context),
                        ),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _applyTemplate(
                            item.example,
                            immediate: item.immediate,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.cmdCapabilitiesFooter,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelHeight = screenHeight < 640
        ? screenHeight * 0.75
        : screenHeight * 0.65;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 72,
      height: panelHeight,
      child: Material(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: _messages.isEmpty
                  ? _buildSuggestions(l10n)
                  : _buildMessageList(),
            ),
            _buildComposer(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(S l10n) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_rounded,
            size: 18,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.cmdAssistantTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showCapabilitiesSheet(l10n),
            icon: const Icon(Icons.auto_awesome_outlined, size: 16),
            label: Text(l10n.cmdCapabilitiesCta),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary(context),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
          IconButton(
            onPressed: widget.onMinimize,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary(context),
            ),
            iconSize: 24,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(S l10n) {
    final suggestions = [
      (l10n.cmdSuggestionAddExpense, l10n.cmdTemplateAddExpense, false),
      (l10n.cmdSuggestionOpenList, 'Abre a lista de compras', true),
      (l10n.cmdSuggestionChangeTheme, l10n.cmdTemplateChangeTheme, false),
      (l10n.cmdSuggestionOpenSettings, 'Abre as definicoes', true),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cmdAssistantHint,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _showCapabilitiesSheet(l10n),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(l10n.cmdCapabilitiesCta),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((s) {
                final (label, template, immediate) = s;
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    _applyTemplate(template, immediate: immediate);
                  },
                  backgroundColor: AppColors.surfaceVariant(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.border(context)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_loading && index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          );
        }
        final msg = _messages[index];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary(context)
                  : msg.isError
                      ? AppColors.errorBackground(context)
                      : msg.isSuccess
                          ? AppColors.successBackground(context)
                          : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser
                    ? AppColors.onPrimary(context)
                    : msg.isError
                        ? AppColors.error(context)
                        : AppColors.textPrimary(context),
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer(S l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: l10n.cmdAssistantHint,
                  hintStyle: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 14,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 34,
            height: 34,
            child: IconButton(
              onPressed: _loading ? null : () => _send(_controller.text),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.textSecondary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: AppColors.surface(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
