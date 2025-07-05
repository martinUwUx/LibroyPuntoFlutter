import 'package:flutter/material.dart';

class TabBarSection extends StatelessWidget {
  final TabController? tabController;
  final List<String> tabs;
  const TabBarSection({super.key, this.tabController, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelStyle: Theme.of(context).textTheme.labelLarge,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}
