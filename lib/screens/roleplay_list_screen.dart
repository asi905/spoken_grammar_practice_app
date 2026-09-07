import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roleplay_screen.dart'; // চ্যাট স্ক্রিন ইম্পোর্ট করা হলো

class RoleplayListScreen extends StatefulWidget {
  const RoleplayListScreen({super.key});

  @override
  State<RoleplayListScreen> createState() => _RoleplayListScreenState();
}

class _RoleplayListScreenState extends State<RoleplayListScreen> {
  List<dynamic> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final String response = await rootBundle.loadString('assets/roles.json');
      final data = await json.decode(response);
      setState(() {
        _roles = data;
      });
    } catch (e) {
      debugPrint("Error loading roles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('রোলপ্লে প্র্যাকটিস'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _roles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.person_pin,
                          color: Colors.indigo, size: 30),
                    ),
                    title: Text(
                      role['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Role: ${role['role_name']} \nCategory: ${role['category']}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.indigo),
                    onTap: () {
                      // এখানে ক্লিক করলে ডাইনামিক চ্যাট স্ক্রিনে যাবে
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleplayScreen(roleData: role),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
