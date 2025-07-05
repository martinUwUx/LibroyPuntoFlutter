import 'package:flutter/material.dart';

class Book {
  final String? id;
  final String image;
  final String editorial;
  final String title;
  final String author;
  final String stock;

  Book({
    this.id,
    required this.image,
    required this.editorial,
    required this.title,
    required this.author,
    required this.stock,
  });
}

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.75,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(book.image, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.editorial, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                const SizedBox(height: 4),
                Text(book.title, style: Theme.of(context).textTheme.titleMedium),
                Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(book.stock, style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
