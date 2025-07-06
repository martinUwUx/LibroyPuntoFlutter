import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/book_card.dart';
import 'widgets/featured_banner.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasPermission = false;

  final List<String> tabs = [
    'Catálogo', 'Destacados', 'Noticias', 'Digitales', 'Desafíos'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _checkAdminPermission();
  }

  Future<void> _checkAdminPermission() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          String? role = userDoc.get('role');
          setState(() {
            _hasPermission = role == 'DLS';
            _isLoading = false;
          });
        } else {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Denegado'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'No tienes permisos para acceder a esta sección.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
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
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: books.length + 1, // +1 para el botón agregar
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddBookDialog(context),
                        icon: Icon(Icons.add),
                        label: Text('Agregar libro'),
                      ),
                    );
                  }
                  
                  final book = books[i - 1];
                  final data = book.data() as Map<String, dynamic>;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.book),
                        title: Text(data['title'] ?? 'Sin título'),
                        subtitle: Text(data['editorial'] ?? 'Sin editorial'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditBookDialog(context, book.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, 'libro', book.id, 'books'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Destacados
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('featured_books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final featuredBooks = snapshot.data?.docs ?? [];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (featuredBooks.isNotEmpty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: FeaturedBannerBox(
                        book: FeaturedBook(
                          image: featuredBooks.first.get('image') ?? 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
                          title: featuredBooks.first.get('title') ?? '¡Libro destacado!',
                          subtitle: featuredBooks.first.get('subtitle') ?? 'El Principito',
                          tags: List<String>.from(featuredBooks.first.get('tags') ?? ['Top Número 1', 'Descarga digital']),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddFeaturedBookDialog(context),
                      icon: Icon(Icons.add),
                      label: Text('Agregar destacado'),
                    ),
                  ),
                ],
              );
            },
          ),
          // Noticias
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('news').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final news = snapshot.data?.docs ?? [];
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: news.length + 1, // +1 para el botón agregar
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddNewsDialog(context),
                        icon: Icon(Icons.add),
                        label: Text('Agregar noticia'),
                      ),
                    );
                  }
                  
                  final newsItem = news[i - 1];
                  final data = newsItem.data() as Map<String, dynamic>;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.announcement),
                        title: Text(data['title'] ?? 'Sin título'),
                        subtitle: Text(data['content'] ?? 'Sin contenido'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditNewsDialog(context, newsItem.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, 'noticia', newsItem.id, 'news'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: digitalBooks.length + 1, // +1 para el botón agregar
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddDigitalBookDialog(context),
                        icon: Icon(Icons.add),
                        label: Text('Agregar libro digital'),
                      ),
                    );
                  }
                  
                  final digitalBook = digitalBooks[i - 1];
                  final data = digitalBook.data() as Map<String, dynamic>;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.download),
                        title: Text(data['title'] ?? 'Sin título'),
                        subtitle: Text(data['author'] ?? 'Sin autor'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDigitalBookDialog(context, digitalBook.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, 'libro digital', digitalBook.id, 'digital_books'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Desafíos
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final challenges = snapshot.data?.docs ?? [];
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: challenges.length + 1, // +1 para el botón agregar
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddChallengeDialog(context),
                        icon: Icon(Icons.add),
                        label: Text('Agregar desafío'),
                      ),
                    );
                  }
                  
                  final challenge = challenges[i - 1];
                  final data = challenge.data() as Map<String, dynamic>;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.emoji_events),
                        title: Text(data['title'] ?? 'Sin título'),
                        subtitle: Text(data['description'] ?? 'Sin descripción'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditChallengeDialog(context, challenge.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, 'desafío', challenge.id, 'challenges'),
                            ),
                          ],
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
    );
  }

  // Funciones CRUD para libros
  void _showAddBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final editorialController = TextEditingController();
    final authorController = TextEditingController();
    final stockController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar libro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: editorialController,
                decoration: InputDecoration(labelText: 'Editorial'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Autor'),
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Stock'),
              ),
              TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'URL de imagen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('books').add({
                'title': titleController.text,
                'editorial': editorialController.text,
                'author': authorController.text,
                'stock': stockController.text,
                'image': imageController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Libro agregado')),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditBookDialog(BuildContext context, String bookId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final editorialController = TextEditingController(text: data['editorial'] ?? '');
    final authorController = TextEditingController(text: data['author'] ?? '');
    final stockController = TextEditingController(text: data['stock'] ?? '');
    final imageController = TextEditingController(text: data['image'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar libro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: editorialController,
                decoration: InputDecoration(labelText: 'Editorial'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Autor'),
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Stock'),
              ),
              TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'URL de imagen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('books').doc(bookId).update({
                'title': titleController.text,
                'editorial': editorialController.text,
                'author': authorController.text,
                'stock': stockController.text,
                'image': imageController.text,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Libro actualizado')),
              );
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Funciones CRUD para libros destacados
  void _showAddFeaturedBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final imageController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar libro destacado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(labelText: 'Subtítulo'),
              ),
              TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'URL de imagen'),
              ),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(labelText: 'Tags (separados por coma)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final tags = tagsController.text.split(',').map((e) => e.trim()).toList();
              await FirebaseFirestore.instance.collection('featured_books').add({
                'title': titleController.text,
                'subtitle': subtitleController.text,
                'image': imageController.text,
                'tags': tags,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Libro destacado agregado')),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // Funciones CRUD para noticias
  void _showAddNewsDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar noticia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('news').add({
                'title': titleController.text,
                'content': contentController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Noticia agregada')),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditNewsDialog(BuildContext context, String newsId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final contentController = TextEditingController(text: data['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar noticia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('news').doc(newsId).update({
                'title': titleController.text,
                'content': contentController.text,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Noticia actualizada')),
              );
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Funciones CRUD para libros digitales
  void _showAddDigitalBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar libro digital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: 'Autor'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('digital_books').add({
                'title': titleController.text,
                'author': authorController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Libro digital agregado')),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditDigitalBookDialog(BuildContext context, String bookId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final authorController = TextEditingController(text: data['author'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar libro digital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: 'Autor'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('digital_books').doc(bookId).update({
                'title': titleController.text,
                'author': authorController.text,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Libro digital actualizado')),
              );
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Funciones CRUD para desafíos
  void _showAddChallengeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar desafío'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('challenges').add({
                'title': titleController.text,
                'description': descriptionController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Desafío agregado')),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditChallengeDialog(BuildContext context, String challengeId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final descriptionController = TextEditingController(text: data['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar desafío'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('challenges').doc(challengeId).update({
                'title': titleController.text,
                'description': descriptionController.text,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Desafío actualizado')),
              );
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Función genérica para eliminar
  void _showDeleteDialog(BuildContext context, String itemType, String itemId, String collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $itemType'),
        content: Text('¿Estás seguro de que quieres eliminar este $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection(collection).doc(itemId).delete();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$itemType eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 