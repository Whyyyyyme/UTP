import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/chat_controller.dart';
import 'package:prelovedly/models/chat_message_model.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final t = c.thread.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (t?.peerPhoto ?? '').isEmpty
                    ? null
                    : NetworkImage(t!.peerPhoto),
                child: (t?.peerPhoto ?? '').isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (t?.peerName ?? 'Chat').toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),

      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ====== LIST PESAN ======
            Expanded(
              child: Obx(() {
                final msgs = c.messages.toList();
                final me = c.me;
                return _MessagesList(me: me, messages: msgs);
              }),
            ),

            // ====== OFFER BANNER (3 versi) ======
            Obx(() {
              if (!c.showOfferBanner) return const SizedBox.shrink();

              return OfferBanner(
                title: c.offerBannerTitle,
                subtitle: c.offerBannerSubtitle,
                offerPriceText: c.rp(c.offerPrice),
                originalPriceText: c.rp(c.originalPrice),
                showActions: c.showOfferActions,
                onReject: c.showOfferActions ? c.rejectOffer : null,
                onAccept: c.showOfferActions ? c.acceptOffer : null,
              );
            }),

            // ====== INPUT ======
            _ChatInput(controller: c.textC, onSend: c.sendText),
          ],
        );
      }),
    );
  }
}

class _MessagesList extends StatefulWidget {
  final String me;
  final List<ChatMessageModel> messages;

  const _MessagesList({required this.me, required this.messages});

  @override
  State<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<_MessagesList> {
  final _scrollC = ScrollController();

  @override
  void didUpdateWidget(covariant _MessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // kalau ada pesan baru, scroll ke bawah
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollC.hasClients) return;
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('Mulai percakapan...'));
    }

    return ListView.builder(
      controller: _scrollC,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        final isMe = m.senderId == widget.me;

        if (m.type == 'system') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: Text(
                m.text,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          );
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              m.text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(icon: const Icon(Icons.send), onPressed: () => onSend()),
          ],
        ),
      ),
    );
  }
}

class OfferBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String offerPriceText;
  final String originalPriceText;

  final bool showActions;
  final Future<void> Function()? onReject;
  final Future<void> Function()? onAccept;

  const OfferBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.offerPriceText,
    required this.originalPriceText,
    required this.showActions,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                offerPriceText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                originalPriceText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),

          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject == null
                        ? null
                        : () async => onReject!(),
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept == null
                        ? null
                        : () async => onAccept!(),
                    icon: const Icon(Icons.check),
                    label: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
