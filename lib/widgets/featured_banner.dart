import 'package:flutter/material.dart';

class FeaturedBook {
  final String image;
  final String title;
  final String subtitle;
  final List<String> tags;

  FeaturedBook({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.tags,
  });
}

class FeaturedBanner extends StatelessWidget {
  final FeaturedBook book;
  const FeaturedBanner({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _buildBanner(context),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(book.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  book.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: book.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.white.withOpacity(0.9),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedBannerBox extends StatelessWidget {
  final FeaturedBook book;
  const FeaturedBannerBox({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return FeaturedBanner(book: book)._buildBanner(context);
  }
}
