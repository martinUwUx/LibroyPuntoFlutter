// lib/challenges_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/search_header.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SearchHeader(),
          const SizedBox(height: 16),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final challenges = snapshot.data?.docs ?? [];
                if (challenges.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay desafíos disponibles',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    final challengeData = challenges[index].data() as Map<String, dynamic>;
                    final timestamp = challengeData['createdAt'] as Timestamp?;
                    final date = timestamp?.toDate();
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      challengeData['title'] ?? 'Sin título',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                challengeData['description'] ?? 'Sin descripción',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (date != null) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${date.day}/${date.month}/${date.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // Aquí iría la lógica para participar en el desafío
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('¡Te has unido al desafío!')),
                                        );
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('Participar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {
                                        // Aquí iría la lógica para ver detalles del desafío
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(challengeData['title'] ?? 'Desafío'),
                                            content: Text(challengeData['description'] ?? 'Sin descripción'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.info),
                                      label: Text('Ver detalles'),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}