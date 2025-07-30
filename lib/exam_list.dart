import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExamList extends StatefulWidget {
  const ExamList({Key? key}) : super(key: key);

  @override
  State<ExamList> createState() => _ExamListState();
}

class _ExamListState extends State<ExamList> {
  List<dynamic> _exams = [];
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      setState(() {
        _error = 'Aucun token trouvé. Veuillez vous reconnecter.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/exams'), // Endpoint fictif, à remplacer par votre API
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _exams = data['exams'] ?? []; // Assurez-vous que l'API renvoie une liste sous la clé 'exams'
        });
      } else {
        setState(() {
          _error = jsonDecode(response.body)['error'] ?? 'Échec du chargement des examens';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur réseau : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Liste des examens'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _error != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : _exams.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun examen disponible',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              exam['name'] ?? 'Examen ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              exam['description'] ?? 'Aucune description',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            onTap: () {
                              // Action au clic sur un examen (à implémenter selon vos besoins)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Examen sélectionné : ${exam['name']}'),
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