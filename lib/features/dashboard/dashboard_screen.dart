import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/dashboard_stats_provider.dart';
import '../../providers/guest_provider.dart';
import '../guest_portal/join_event_modal.dart';

// =============================================================================
// UNIFIED DASHBOARD SCREEN
// =============================================================================

/// Unified Dashboard — overview of the user's wedding planning & attending workspace.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(currentUserModelProvider).valueOrNull;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.cream,
      drawer: _AppDrawer(
        userModel: userModel,
        ref: ref,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'join_event',
            onPressed: () {
              showJoinEventModal(context);
            },
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.brandInk, width: 1),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.brandInk),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create_event',
            onPressed: () => context.push('/event/create'),
            backgroundColor: AppColors.brandInk,
            child: const Icon(Icons.add, color: AppColors.surface),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _DashboardHeader(
                userModel: userModel,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('Overview', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    const _StatsGrid(),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: AppColors.brandInk,
                    unselectedLabelColor: AppColors.stone,
                    indicatorColor: AppColors.brandInk,
                    tabs: const [
                      Tab(text: 'Hosting'),
                      Tab(text: 'Attending'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              _HostingTabView(),
              _AttendingTabView(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab Views ─────────────────────────────────────────────────────────────────

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.cream,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _HostingTabView extends StatelessWidget {
  const _HostingTabView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HostEventsList(),
        ],
      ),
    );
  }
}

class _AttendingTabView extends StatelessWidget {
  const _AttendingTabView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: _AttendingEventsList(),
    );
  }
}

// ── Sidebar Drawer ────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.userModel,
    required this.ref,
  });

  final UserModel? userModel;
  final WidgetRef ref;

  static const List<_DrawerItem> _items = [
    _DrawerItem(
        icon: Icons.event_rounded,
        label: 'Events',
        iconColor: AppColors.accentBlue,
        bgColor: Color(0xFFEEF4FF)),
    _DrawerItem(
        icon: Icons.people_outline_rounded,
        label: 'Guests',
        iconColor: AppColors.accentPink,
        bgColor: Color(0xFFFDF0FB)),
    _DrawerItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Budget',
        iconColor: AppColors.statusPending,
        bgColor: Color(0xFFFDF8EC)),
    _DrawerItem(
        icon: Icons.card_giftcard_rounded,
        label: 'Gifts',
        iconColor: AppColors.statusAccepted,
        bgColor: Color(0xFFEEF7F2)),
    _DrawerItem(
        icon: Icons.qr_code_rounded,
        label: 'Invitations',
        iconColor: AppColors.brandInk,
        bgColor: Color(0xFFE8EAF6)),
    _DrawerItem(
        icon: Icons.checklist_rounded,
        label: 'Items',
        iconColor: AppColors.brandInkLight,
        bgColor: Color(0xFFF3EDE8)),
    _DrawerItem(
        icon: Icons.photo_library_outlined,
        label: 'Memories',
        iconColor: AppColors.statusCheckedIn,
        bgColor: Color(0xFFEBF2F8)),
    _DrawerItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Subscription Plan',
        iconColor: AppColors.accentPink,
        bgColor: Color(0xFFFDF0FB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      width: MediaQuery.of(context).size.width * 0.78,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _DrawerHeader(userModel: userModel, ref: ref),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _DrawerTile(item: _items[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: const Color(0xFFFFF0F0),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.statusDeclined.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.statusDeclined, size: 18),
              ),
              title: Text('Sign Out',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.statusDeclined)),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.userModel, required this.ref});
  final UserModel? userModel;
  final WidgetRef ref;

  String get userName => userModel?.name ?? 'Host';
  String get userEmail => userModel?.email ?? '';

  Future<void> _handleAvatarTap(BuildContext context) async {
    final hasPhoto =
        userModel?.photoUrl != null && userModel!.photoUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text('Profile Photo',
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.brandInk)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: AppColors.accentBlue),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUpload(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.accentPink),
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUpload(context, ImageSource.camera);
                  },
                ),
                if (hasPhoto) ...[
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusDeclined.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.statusDeclined),
                    ),
                    title: const Text('Remove Photo',
                        style: TextStyle(color: AppColors.statusDeclined)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .updateUserAvatar(null);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Avatar removed successfully.')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to remove avatar: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 50,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Updating avatar...'),
              duration: Duration(seconds: 1)),
        );
      }

      await ref
          .read(authNotifierProvider.notifier)
          .updateUserAvatar(base64String);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  Widget _buildAvatarWidget() {
    final photoUrl = userModel?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            photoUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person_outline_rounded,
                color: AppColors.charcoal,
                size: 26),
          ),
        );
      } else {
        try {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(photoUrl),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.charcoal,
                  size: 26),
            ),
          );
        } catch (_) {
          return const Icon(Icons.person_outline_rounded,
              color: AppColors.charcoal, size: 26);
        }
      }
    }
    return const Icon(Icons.person_outline_rounded,
        color: AppColors.charcoal, size: 26);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(24)),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        decoration:
                            const BoxDecoration(gradient: AppGradients.heroBlue))),
                Expanded(
                    child: Container(
                        decoration:
                            const BoxDecoration(gradient: AppGradients.heroPink))),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _handleAvatarTap(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.brandInk, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.ink.withAlpha(15),
                                blurRadius: 8)
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _buildAvatarWidget(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.brandInk,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surface, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 10,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.brandInk),
                          overflow: TextOverflow.ellipsis),
                      if (userEmail.isNotEmpty)
                        Text(userEmail,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.charcoal),
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
}

class _DrawerTile extends ConsumerWidget {
  const _DrawerTile({required this.item});
  final _DrawerItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: item.bgColor,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: item.bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(item.icon, color: item.iconColor, size: 19),
      ),
      title: Text(item.label, style: AppTextStyles.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.stone, size: 20),
      onTap: () {
        final router = GoRouter.of(context);
        final navigator = Navigator.of(context);
        final rootContext = navigator.context; // The navigator's context stays active
        navigator.pop(); // close drawer

        if (item.label == 'Events') {
          router.push('/events');
        } else if (item.label == 'Guests') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/guests');
          });
        } else if (item.label == 'Items') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/checklist');
          });
        } else if (item.label == 'Budget') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/budget');
          });
        } else if (item.label == 'Invitations') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/invitation');
          });
        } else if (item.label == 'Gifts') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/gifts/wallet');
          });
        } else if (item.label == 'Memories') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/memories');
          });
        } else if (item.label == 'Subscription Plan') {
          _showEventPicker(rootContext, ref, (eventId) {
            GoRouter.of(rootContext).push('/event/$eventId/premium');
          });
        }
      },
    );
  }

  void _showEventPicker(
      BuildContext context, WidgetRef ref, Function(String) onEventSelected) {
    final hostEvents = ref.read(hostEventsProvider).valueOrNull ?? [];
    if (hostEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to create an event first.')),
      );
      return;
    }
    
    // If only one event, just go directly
    if (hostEvents.length == 1) {
      onEventSelected(hostEvents.first.id);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Event',
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
                  ),
                ),
                const SizedBox(height: 16),
                ...hostEvents.map((e) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(e.title, style: AppTextStyles.titleMedium),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(e.date)),
                      onTap: () {
                        Navigator.pop(ctx);
                        onEventSelected(e.id);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.userModel, required this.onMenuTap});
  final UserModel? userModel;
  final VoidCallback onMenuTap;

  String get userName => userModel?.name ?? 'Host';

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildMiniAvatar() {
    final photoUrl = userModel?.photoUrl;
    Widget placeholder = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandInk, width: 1),
      ),
      child: const Icon(Icons.person_outline_rounded, color: AppColors.brandInk, size: 32),
    );

    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            photoUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          ),
        );
      } else {
        try {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(photoUrl),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
          );
        } catch (_) {
          return placeholder;
        }
      }
    }
    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: Container(
                  decoration:
                      const BoxDecoration(gradient: AppGradients.heroBlue))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Opacity(
              opacity: 0.6,
              child: Container(
                  decoration:
                      const BoxDecoration(gradient: AppGradients.heroPink)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _HeaderButton(
                          icon: Icons.menu_rounded,
                          color: AppColors.brandInk,
                          onTap: onMenuTap),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.ink.withAlpha(15),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: _buildMiniAvatar(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.brandInkLight,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Good $_greeting,',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.charcoal, fontSize: 18)),
                            const SizedBox(height: 2),
                            Text(userName, 
                                style: AppTextStyles.headlineMedium.copyWith(fontSize: 28, height: 1.1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostEventsCount =
        ref.watch(hostEventsProvider).valueOrNull?.length ?? 0;
    final attendingEventsCount =
        ref.watch(attendingEventsProvider).valueOrNull?.length ?? 0;
    final totalEvents = hostEventsCount + attendingEventsCount;
    final stats = ref.watch(dashboardStatsProvider);
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(
            label: 'Events',
            value: '$totalEvents',
            icon: Icons.event_rounded,
            iconColor: AppColors.accentBlue,
            bgColor: const Color(0xFFDFEBFF)),
        _StatCard(
            label: 'Guests',
            value: '${stats.totalGuests}',
            icon: Icons.people_outline_rounded,
            iconColor: AppColors.accentPink,
            bgColor: const Color(0xFFFFE4FA)),
        _StatCard(
            label: 'Tasks Done',
            value: '${(stats.tasksDonePercent * 100).toInt()}%',
            icon: Icons.checklist_rounded,
            iconColor: AppColors.statusAccepted,
            bgColor: const Color(0xFFD9F0E4)),
        _StatCard(
            label: 'Budget Used',
            value: formatCurrency.format(stats.budgetUsed),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.statusPending,
            bgColor: const Color(0xFFFFF0CC)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandInk, width: 1),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.brandInk)),
              Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.charcoal)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Host Events List ──────────────────────────────────────────────────────────

class _HostEventsList extends ConsumerWidget {
  const _HostEventsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(hostEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brandInk, width: 1),
            ),
            child: const Center(
              child: Text(
                'No events yet. Create one to get started!',
                style: TextStyle(color: AppColors.stone),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = events[index];
            return GestureDetector(
              onTap: () => context.push('/event/${event.id}'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandInk, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.brandInk),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.accentBlue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              DateFormat('MMM d, yyyy').format(event.date),
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.charcoal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.brandInk),
        ),
      ),
      error: (err, _) => Text('Error loading events: $err'),
    );
  }
}

// ── Attending Events List ─────────────────────────────────────────────────────

class _AttendingEventsList extends ConsumerWidget {
  const _AttendingEventsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(attendingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brandInk, width: 1),
            ),
            child: const Center(
              child: Text(
                'You have not joined any events yet.',
                style: TextStyle(color: AppColors.stone),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = events[index];
            return Consumer(
              builder: (context, ref, child) {
                final guestStatus = ref.watch(currentGuestStatusProvider(event.id)).valueOrNull;
                final isPending = guestStatus?.status == 'requested';

                return GestureDetector(
                  onTap: () {
                    // Navigate to AttendingScreen (Event Details)
                    context.push('/event/${event.id}/attending');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brandInk, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppTextStyles.titleMedium
                                    .copyWith(color: AppColors.brandInk),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 12, color: AppColors.accentBlue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM d, yyyy').format(event.date),
                                      style: AppTextStyles.labelSmall
                                          .copyWith(color: AppColors.charcoal),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isPending)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppColors.statusPending.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.statusPending, width: 1),
                            ),
                            child: Text(
                              'Pending',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.statusPending),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.brandInk),
        ),
      ),
      error: (err, _) => Text('Error loading events: $err'),
    );
  }
}
