import 'package:flutter/material.dart';

class LabelSort extends StatelessWidget {
  final String label;
  const LabelSort({super.key, this.label = 'Ordenar'});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.swap_vert, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
