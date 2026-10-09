import 'package:flutter/material.dart';

const TextStyle kNoDeco = TextStyle(
  decoration: TextDecoration.none,
  decorationColor: Colors.transparent,
);

// ═══════ Stat Card ═══════
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> colors;
  final bool loading;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kNoDeco.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (loading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Text(
              '$value',
              style: kNoDeco.copyWith(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════ Icon Button ═══════
class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool spinning;
  final Color? color;

  const IconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.spinning = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: spinning
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color ?? theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: color ?? theme.colorScheme.onSurface,
                ),
        ),
      ),
    );
  }
}

// ═══════ Action Button ═══════
class ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool busy;
  final VoidCallback? onTap;

  const ActionBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.busy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onTap == null
              ? [
                  gradient.first.withOpacity(0.4),
                  gradient.last.withOpacity(0.4),
                ]
              : gradient,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(onTap == null ? 0.1 : 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: kNoDeco.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════ Log Panel ═══════
class LogPanel extends StatelessWidget {
  final ValueNotifier<List<String>> logs;
  final double height;

  const LogPanel({
    super.key,
    required this.logs,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded,
                  size: 13, color: theme.colorScheme.primary),
              const SizedBox(width: 5),
              Text(
                'السجل',
                style: kNoDeco.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: logs,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'لا يوجد سجل بعد',
                      style: kNoDeco.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      list[i],
                      style: kNoDeco.copyWith(
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}