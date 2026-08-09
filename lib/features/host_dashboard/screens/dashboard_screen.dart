import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

/// Host Dashboard — overview of the host's wedding planning workspace.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(currentUserModelProvider);
    final userName = userModel.valueOrNull?.name ?? 'Host';
    final userEmail = userModel.valueOrNull?.email ?? '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.cream,
      drawer: _AppDrawer(
        userName: userName,
        userEmail: userEmail,
        ref: ref,
      ),
      body: CustomScrollView(
        slivers: [
          _DashboardHeader(
            userName: userName,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Overview', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                const _StatsGrid(),
                const SizedBox(height: 28),
                Text('Recent Activity', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                const _RecentActivity(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sidebar Drawer ────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.userName,
    required this.userEmail,
    required this.ref,
  });

  final String userName;
  final String userEmail;
  final WidgetRef ref;

  static const List<_DrawerItem> _items = [
    _DrawerItem(icon: Icons.event_rounded,                  label: 'Events',            iconColor: AppColors.accentBlue,       bgColor: Color(0xFFEEF4FF)),
    _DrawerItem(icon: Icons.people_outline_rounded,          label: 'Guests',            iconColor: AppColors.accentPink,       bgColor: Color(0xFFFDF0FB)),
    _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Budget',            iconColor: AppColors.statusPending,    bgColor: Color(0xFFFDF8EC)),
    _DrawerItem(icon: Icons.card_giftcard_rounded,           label: 'Gifts',             iconColor: AppColors.statusAccepted,   bgColor: Color(0xFFEEF7F2)),
    _DrawerItem(icon: Icons.checklist_rounded,               label: 'Items',             iconColor: AppColors.brandInkLight,    bgColor: Color(0xFFF3EDE8)),
    _DrawerItem(icon: Icons.photo_library_outlined,          label: 'Memories',          iconColor: AppColors.statusCheckedIn,  bgColor: Color(0xFFEBF2F8)),
    _DrawerItem(icon: Icons.workspace_premium_outlined,      label: 'Subscription Plan', iconColor: AppColors.accentPink,       bgColor: Color(0xFFFDF0FB)),
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
          _DrawerHeader(userName: userName, userEmail: userEmail),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  const _DrawerHeader({required this.userName, required this.userEmail});
  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
            child: Row(
              children: [
                Expanded(child: Container(decoration: const BoxDecoration(gradient: AppGradients.heroBlue))),
                Expanded(child: Container(decoration: const BoxDecoration(gradient: AppGradients.heroPink))),
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider, width: 2),
                    boxShadow: [BoxShadow(color: AppColors.ink.withAlpha(15), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: AppColors.charcoal, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
                          overflow: TextOverflow.ellipsis),
                      if (userEmail.isNotEmpty)
                        Text(userEmail,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
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

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.item});
  final _DrawerItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: item.bgColor,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: item.bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(item.icon, color: item.iconColor, size: 19),
      ),
      title: Text(item.label, style: AppTextStyles.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.stone, size: 20),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.userName, required this.onMenuTap});
  final String userName;
  final VoidCallback onMenuTap;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 200,
            child: Container(decoration: const BoxDecoration(gradient: AppGradients.heroBlue))),
          Positioned(
            top: 0, left: 0, right: 0, height: 200,
            child: Opacity(
              opacity: 0.6,
              child: Container(decoration: const BoxDecoration(gradient: AppGradients.heroPink)),
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
                      _HeaderButton(icon: Icons.menu_rounded, color: AppColors.brandInk, onTap: onMenuTap),
                      const Spacer(),
                      _HeaderButton(icon: Icons.notifications_none_rounded, color: AppColors.charcoal, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Good $_greeting,',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal)),
                  Text(userName, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Plan your perfect celebration 🎉',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
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
  const _HeaderButton({required this.icon, required this.color, required this.onTap});
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
          color: AppColors.surface.withAlpha(200),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: const [
        _StatCard(label: 'Events',     value: '0',  icon: Icons.event_rounded,                   iconColor: AppColors.accentBlue,      bgColor: Color(0xFFDFEBFF)),
        _StatCard(label: 'Guests',     value: '0',  icon: Icons.people_outline_rounded,           iconColor: AppColors.accentPink,      bgColor: Color(0xFFFFE4FA)),
        _StatCard(label: 'Tasks Done', value: '0%', icon: Icons.checklist_rounded,                iconColor: AppColors.statusAccepted,  bgColor: Color(0xFFD9F0E4)),
        _StatCard(label: 'Budget Used',value: '৳0', icon: Icons.account_balance_wallet_outlined,  iconColor: AppColors.statusPending,   bgColor: Color(0xFFFFF0CC)),
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
        border: Border.all(color: AppColors.divider),
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
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk)),
              Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent Activity ───────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: const [
          _ActivityItem(
            icon: Icons.celebration_outlined,
            iconColor: AppColors.accentBlue,
            title: 'Welcome to Munasabat!',
            subtitle: 'Create your first wedding event to get started.',
            isLast: false,
          ),
          _ActivityItem(
            icon: Icons.tips_and_updates_outlined,
            iconColor: AppColors.accentPink,
            title: 'Tip: Add your guests early',
            subtitle: 'Invitations with QR codes are generated automatically.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }
}
