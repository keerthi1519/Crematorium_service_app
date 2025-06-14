import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';


class UseCase {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  UseCase({required this.id, required this.name, required this.description, required this.icon});

  factory UseCase.fromJson(Map<String, dynamic> json) {
    return UseCase(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: Icons.check_circle, // Default icon, customize based on data
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final SupabaseClient supabase = SupabaseService.client;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  List<UseCase> useCases = [];
  List<UseCase> filteredUseCases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUseCases();
    searchController.addListener(_filterUseCases);
  }

  Future<void> _fetchUseCases() async {
    try {
      final response = await supabase.from('use_cases').select();
      setState(() {
        useCases = response.map<UseCase>((json) => UseCase.fromJson(json)).toList();
        filteredUseCases = List.from(useCases);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching use cases: $e");
    }
  }

  void _filterUseCases() {
    setState(() {
      filteredUseCases = useCases
          .where((useCase) =>
          useCase.name.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _scrollToItem(int index) {
    scrollController.animateTo(
      index * 100.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accessibility Tests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Use Cases...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading animation
                : ListView.builder(
              controller: scrollController,
              itemCount: filteredUseCases.length,
              itemBuilder: (context, index) {
                final useCase = filteredUseCases[index];
                return Card(
                  key: Key(useCase.id),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(useCase.icon, color: Colors.blue),
                    title: Text(useCase.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(useCase.description),
                    onTap: () {
                      _scrollToItem(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Running ${useCase.name} test...')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
