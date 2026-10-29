import 'dart:async';

import 'package:flutter/material.dart';
import 'package:holyquran/dua_service.dart';
import 'package:holyquran/duadetil.dart';

class DuaCategoriesScreen extends StatefulWidget {
  const DuaCategoriesScreen({super.key});

  @override
  State<DuaCategoriesScreen> createState() => _DuaCategoriesScreenState();
}

class _DuaCategoriesScreenState extends State<DuaCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get _filteredCategories {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _categories;

    return _categories.where((category) {
      return category['title'].toString().toLowerCase().contains(query) ||
          category['englishTitle'].toString().toLowerCase().contains(query) ||
          category['id'].toString() == query;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await DuaService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load dua categories. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openCategory(Map<String, dynamic> category) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DuaDetailScreen(category: category),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories;

    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        foregroundColor: Colors.white,
        title: const Text('عام دعائیں'),
        actions: [
          IconButton(
            tooltip: 'Refresh categories',
            onPressed: _isLoading ? null : _loadCategories,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'دعائیں تلاش کریں',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                filled: true,
                fillColor: const Color(0xff0A5448),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildCategoryBody(filteredCategories)),
        ],
      ),
    );
  }

  Widget _buildCategoryBody(List<Map<String, dynamic>> categories) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xffF4B400)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xffF4B400),
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadCategories,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffF4B400),
                  foregroundColor: const Color(0xff033B33),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No matching categories',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xff0A5448),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              onTap: () => _openCategory(category),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 3,
              ),
               
              title: Text(
                category['title'].toString(),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
              ),
            ),
          ),
        );
      },
    );
  }
}
