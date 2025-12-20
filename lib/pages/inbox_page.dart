import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/inbox_controller.dart';
import 'package:prelovedly/models/inbox_thread_model.dart';
import 'package:prelovedly/routes/app_routes.dart'; // ✅ sesuaikan

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InboxController>();
    return Obx(() {
      final uid = c.session.viewerId.value;

      if (uid.isEmpty) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Inbox', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        body: StreamBuilder<List<InboxThreadModel>>(
          stream: c.threadsStream(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snap.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada pesan',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final t = items[i];
                final isActivity = t.type == 'activity';

                final title = isActivity
                    ? 'Aktivitas'
                    : (t.peerUsername.isNotEmpty ? t.peerUsername : 'User');

                final subtitle = t.lastMessage.isNotEmpty ? t.lastMessage : '-';

                return InkWell(
                  onTap: () {
                    if (isActivity) {
                      Get.snackbar('Info', 'Halaman Aktivitas (TODO)');
                      return;
                    }
                    Get.toNamed(
                      Routes.chat,
                      arguments: {
                        'threadId': t.threadId,
                        'peerId': t.peerId,
                        'productId': t.productId.isEmpty
                            ? 'general'
                            : t.productId,
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _Avatar(
                          isActivity: isActivity,
                          photoUrl: t.peerPhoto,
                          fallbackText: title,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              c.formatTime(t.lastTime),
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 6),

                            if (t.unreadCount > 0)
                              isActivity
                                  ? _UnreadBadge(count: t.unreadCount)
                                  : const _UnreadDot(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }
}

class _Avatar extends StatelessWidget {
  final bool isActivity;
  final String photoUrl;
  final String fallbackText;

  const _Avatar({
    required this.isActivity,
    required this.photoUrl,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActivity ? const Color(0xFFFF4D6D) : Colors.pink.shade400;

    return CircleAvatar(
      radius: 26,
      backgroundColor: bg.withOpacity(0.9),
      backgroundImage: (!isActivity && photoUrl.isNotEmpty)
          ? NetworkImage(photoUrl)
          : null,
      child: isActivity
          ? const Icon(Icons.notifications_none, color: Colors.white)
          : (photoUrl.isEmpty
                ? Text(
                    fallbackText.isNotEmpty
                        ? fallbackText[0].toLowerCase()
                        : 'u',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  )
                : null),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
