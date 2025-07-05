import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const SearchHeader({super.key, this.hint = '¿Buscas algo?', this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
