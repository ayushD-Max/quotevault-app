import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/features/auth/auth_service.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';
import 'package:quotevault/settings/settings_screen.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'package:quotevault/features/profile/edit_name_dialog.dart';
import 'package:quotevault/features/profile/collections_screen.dart';
import 'package:quotevault/features/profile/collection_detail_screen.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final email = user?.email ?? '';

    final nameAsync = ref.watch(profileFullNameProvider);
    final favCountAsync = ref.watch(favoritesCountProvider);
    final colCountAsync = ref.watch(collectionsCountProvider);
    final recentAsync = ref.watch(recentCollectionsProvider);

    Future<void> _openCollections() async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CollectionsScreen()));
      ref.invalidate(recentCollectionsProvider);
      ref.invalidate(collectionsCountProvider);
    }

    return Scaffold(
      backgroundColor: qvBg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: qvText(context),
                            ),
                      ),
                    ),
                    QVCircleIconButton(
                      icon: Icons.settings_rounded,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen(asTab: false)));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        QVColors.primary.withOpacity(qvIsDark(context) ? 0.18 : 0.12),
                        QVColors.primary.withOpacity(0.06),
                      ],
                    ),
                    border: Border.all(color: QVColors.primary.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      _InitialsAvatar(name: nameAsync.value ?? '', email: email),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            nameAsync.when(
                              loading: () => Text('Loading…', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                              error: (_, __) => Text('Your Name', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                              data: (name) => Text(
                                name.isEmpty ? 'Your Name' : name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email.isEmpty ? 'you@example.com' : email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: qvText(context).withOpacity(0.70),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final current = nameAsync.value ?? '';
                          final newName = await showDialog<String>(
                            context: context,
                            builder: (_) => EditNameDialog(initial: current),
                          );
                          if (newName == null) return;
                          if (user == null) return;

                          final client = ref.read(supabaseClientProvider);
                          await client.from('profiles').update({'full_name': newName}).eq('id', user.id);
                          ref.invalidate(profileFullNameProvider);
                        },
                        child: Text(
                          'Edit',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QVColors.primary, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Quotes saved', valueAsync: favCountAsync)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Collections', valueAsync: colCountAsync)),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent collections',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: qvText(context)),
                      ),
                    ),
                    TextButton(
                      onPressed: _openCollections,
                      child: Text(
                        'View all',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QVColors.primary, fontWeight: FontWeight.w900),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                recentAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: QVColors.primary))),
                  error: (e, _) => Text('Failed: $e', style: TextStyle(color: qvText(context))),
                  data: (items) {
                    if (items.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: qvSurface(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08)),
                        ),
                        child: Text(
                          'No collections yet.\nCreate one from Collections.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: qvText(context).withOpacity(0.65),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 4 / 5,
                      ),
                      itemBuilder: (context, i) {
                        final c = items[i];
                        final id = (c['id'] as num).toInt();
                        final title = (c['title'] as String?) ?? 'Collection';

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CollectionDetailScreen(collectionId: id, title: title)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  QVColors.primary.withOpacity(0.16),
                                  QVColors.primary.withOpacity(0.06),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: QVColors.primary.withOpacity(0.14)),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.collections_bookmark_rounded, color: QVColors.primary),
                                const Spacer(),
                                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 6),
                                Text('Tap to open', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: qvText(context).withOpacity(0.6), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 18),

                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    onLogout();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    side: BorderSide(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: qvText(context)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  final String email;
  const _InitialsAvatar({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    String initial = 'Q';
    final n = name.trim();
    if (n.isNotEmpty) {
      initial = n[0].toUpperCase();
    } else if (email.trim().isNotEmpty) {
      initial = email.trim()[0].toUpperCase();
    }

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: qvSurface(context),
        border: Border.all(color: QVColors.primary.withOpacity(0.22)),
      ),
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: QVColors.primary),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final AsyncValue<int> valueAsync;
  const _StatCard({required this.label, required this.valueAsync});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          valueAsync.when(
            loading: () => Text('—', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            error: (_, __) => Text('—', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            data: (v) => Text('$v', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: qvText(context).withOpacity(0.7), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}