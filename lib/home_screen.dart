// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lypflutter2/qr_id_screen.dart';
import 'widgets/search_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/featured_banner.dart';
import 'widgets/book_card.dart';
import 'widgets/chips_filter.dart';
import 'widgets/label_sort.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  String selectedFilter = 'Todos';
  String selectedSort = 'Más recientes';

  final List<String> filters = ['Todos', 'Ficción', 'No ficción', 'Ciencia', 'Historia'];
  final List<String> sortOptions = ['Más recientes', 'Más antiguos', 'A-Z', 'Z-A'];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SearchHeader(),
            const SizedBox(height: 16),
            
            // Banner destacado
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('featured_books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final featuredBooks = snapshot.data?.docs ?? [];
                if (featuredBooks.isEmpty) {
                  return Container();
                }
                
                final featuredBook = featuredBooks.first.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FeaturedBannerBox(
                    book: FeaturedBook(
                      image: featuredBook['image'] ?? 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
                      title: featuredBook['title'] ?? '¡Libro destacado!',
                      subtitle: featuredBook['subtitle'] ?? 'El Principito',
                      tags: List<String>.from(featuredBook['tags'] ?? ['Top Número 1', 'Descarga digital']),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Filtros y ordenamiento
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ChipsFilter(
                    filters: filters,
                    selectedFilter: selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  LabelSort(
                    sortOptions: sortOptions,
                    selectedSort: selectedSort,
                    onSortChanged: (sort) {
                      setState(() {
                        selectedSort = sort;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Catálogo de libros
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final books = snapshot.data?.docs ?? [];
                if (books.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay libros disponibles',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Aplicar filtros y ordenamiento
                List<QueryDocumentSnapshot> filteredBooks = books;
                
                // Ordenamiento
                switch (selectedSort) {
                  case 'Más recientes':
                    filteredBooks.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime);
                    });
                    break;
                  case 'Más antiguos':
                    filteredBooks.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return aTime.compareTo(bTime);
                    });
                    break;
                  case 'A-Z':
                    filteredBooks.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTitle = aData['title'] ?? '';
                      final bTitle = bData['title'] ?? '';
                      return aTitle.compareTo(bTitle);
                    });
                    break;
                  case 'Z-A':
                    filteredBooks.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTitle = aData['title'] ?? '';
                      final bTitle = bData['title'] ?? '';
                      return bTitle.compareTo(aTitle);
                    });
                    break;
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final bookData = filteredBooks[index].data() as Map<String, dynamic>;
                    return BookCard(
                      book: Book(
                        id: filteredBooks[index].id,
                        title: bookData['title'] ?? 'Sin título',
                        author: bookData['author'] ?? 'Sin autor',
                        editorial: bookData['editorial'] ?? 'Sin editorial',
                        image: bookData['image'] ?? 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
                        stock: bookData['stock'] ?? '0',
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}