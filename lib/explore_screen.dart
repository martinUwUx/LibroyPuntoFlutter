// lib/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/search_header.dart';
import 'widgets/featured_banner.dart';
import 'widgets/tabbar_section.dart';
import 'widgets/chips_filter.dart';
import 'widgets/label_sort.dart';
import 'widgets/book_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'Todos';
  String selectedSort = 'Más recientes';

  final List<String> filters = ['Todos', 'Ficción', 'No ficción', 'Ciencia', 'Historia'];
  final List<String> sortOptions = ['Más recientes', 'Más antiguos', 'A-Z', 'Z-A'];

  final featuredBooks = [
    FeaturedBook(
      image: 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
      title: '¡Libro destacado!',
      subtitle: 'El Principito',
      tags: ['Top Número 1', 'Descarga digital'],
    ),
    // Puedes agregar más libros destacados aquí
  ];

  final List<Book> catalogBooks = [
    Book(
      image: 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
      editorial: 'Santillana',
      title: 'El Principito',
      author: 'Antoine de Saint-Exupéry',
      stock: '13 Un. + Dig.',
    ),
    Book(
      image: 'https://images.unsplash.com/photo-1524985069026-dd778a71c7b4',
      editorial: 'Salamandra',
      title: 'El Principito',
      author: 'Antoine de Saint-Exupéry',
      stock: '3 Un.',
    ),
    Book(
      image: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
      editorial: 'El Gato De Hojalata',
      title: 'El Principito',
      author: 'Antoine de Saint-Exupéry',
      stock: 'Solo Dig.',
    ),
    Book(
      image: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353',
      editorial: 'Planeta Junior',
      title: 'El Principito',
      author: 'Antoine de Saint-Exupéry',
      stock: 'Agotado',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SearchHeader(),
          const SizedBox(height: 16),
          
          TabBarSection(
            tabController: _tabController,
            tabs: ['Catálogo', 'Digitales'],
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Catálogo
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay libros disponibles',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
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
                    
                    return Column(
                      children: [
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
                        
                        const SizedBox(height: 16),
                        
                        // Lista de libros
                        Expanded(
                          child: GridView.builder(
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
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          image: Uri.tryParse(bookData['image'] ?? '')?.hasAbsolutePath == true
                                            ? DecorationImage(
                                                image: NetworkImage(bookData['image'] ?? 'https://images.unsplash.com/photo-1512820790803-83ca734da794'),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: NetworkImage('https://images.unsplash.com/photo-1512820790803-83ca734da794'),
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bookData['title'] ?? 'Sin título',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              bookData['author'] ?? 'Sin autor',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Icon(Icons.inventory, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Stock: ${bookData['stock'] ?? '0'}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                // Digitales
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('digital_books').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final digitalBooks = snapshot.data?.docs ?? [];
                    if (digitalBooks.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay libros digitales disponibles',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: digitalBooks.length,
                      itemBuilder: (context, index) {
                        final bookData = digitalBooks[index].data() as Map<String, dynamic>;
                        final timestamp = bookData['createdAt'] as Timestamp?;
                        final date = timestamp?.toDate();
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1512820790803-83ca734da794'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                bookData['title'] ?? 'Sin título',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bookData['author'] ?? 'Sin autor'),
                                  if (date != null)
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${date.day}/${date.month}/${date.year}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: FilledButton.icon(
                                onPressed: () {
                                  // Aquí iría la lógica para descargar el libro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Descargando ${bookData['title'] ?? 'libro'}...')),
                                  );
                                },
                                icon: Icon(Icons.download),
                                label: Text('Descargar'),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}