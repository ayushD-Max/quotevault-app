import 'package:flutter/material.dart';

Future<void> showAppMoreSheet({
  required BuildContext context,
  required VoidCallback onCollections,
  required VoidCallback onSettings,
  required VoidCallback onLogout,
}) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Item(icon: Icons.collections_bookmark_rounded, label: 'My Collections', onTap: () {
              Navigator.pop(context);
              onCollections();
            }),
            _Item(icon: Icons.settings_rounded, label: 'Settings', onTap: () {
              Navigator.pop(context);
              onSettings();
            }),
            const Divider(),
            _Item(icon: Icons.logout_rounded, label: 'Logout', danger: true, onTap: () {
              Navigator.pop(context);
              onLogout();
            }),
          ],
        ),
      );
    },
  );
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _Item({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}