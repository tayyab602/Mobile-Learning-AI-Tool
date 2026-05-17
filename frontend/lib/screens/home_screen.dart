import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resource.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/resource_card.dart';
import 'resource_detail_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Resource>> _resourcesFuture;
  String _selectedCategory = '';
  String _selectedDifficulty = '';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  void _loadResources() {
    setState(() {
      _resourcesFuture = ApiService.getAllResources(
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
        difficulty: _selectedDifficulty.isNotEmpty ? _selectedDifficulty : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Assistant'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(),
                ),
              );
            },
            tooltip: 'Chatbot',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        'All',
                        '',
                      ),
                      _buildCategoryChip(
                        'Software Dev',
                        'software_development',
                      ),
                      _buildCategoryChip(
                        'Web Dev',
                        'web_development',
                      ),
                      _buildCategoryChip(
                        'Mobile Dev',
                        'mobile_app_development',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Difficulty Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Difficulty chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDifficultyChip('All', ''),
                      _buildDifficultyChip('Beginner', 'beginner'),
                      _buildDifficultyChip('Intermediate', 'intermediate'),
                      _buildDifficultyChip('Advanced', 'advanced'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Resources list
          Expanded(
            child: FutureBuilder<List<Resource>>(
              future: _resourcesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget(
                    message: 'Loading resources...',
                  );
                }

                if (snapshot.hasError) {
                  return ErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: _loadResources,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No resources found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final resources = snapshot.data!;
                return ListView.builder(
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    return ResourceCard(
                      resource: resources[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResourceDetailScreen(
                              resource: resources[index],
                            ),
                          ),
                        );
                      },
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

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : '';
            _selectedDifficulty = ''; // Reset difficulty filter
            _loadResources();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF1976D2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String value) {
    final isSelected = _selectedDifficulty == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedDifficulty = selected ? value : '';
            _loadResources();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF1976D2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
