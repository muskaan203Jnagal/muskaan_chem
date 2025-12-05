// ============================================================================
// lib/admin/users.dart (FINAL CORRECTED VERSION)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Firestore collection name
const String _userCollectionName = 'users';

/// Represents a single user document from Firestore.
class UserModel {
  final String id;
  final String avatarLetter;
  final Timestamp createdAt;
  final String email;
  final String name;
  final String phone;
  final Timestamp updatedAt;

  UserModel({
    required this.id,
    required this.avatarLetter,
    required this.createdAt,
    required this.email,
    required this.name,
    required this.phone,
    required this.updatedAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      avatarLetter: data['avatarLetter'] ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      email: data['email'] ?? 'N/A',
      name: data['name'] ?? 'N/A',
      phone: data['phone'] ?? 'N/A',
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 10;
  final TextEditingController _searchController = TextEditingController();

  // State for data management
  int _totalUsersCount = 0;
  List<UserModel> _users = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument; // For server-side pagination
  String _currentSearchTerm = '';
  String _sortField = 'createdAt'; // Default sort field
  bool _sortAscending = false; // Default sort order (most recent first)

  @override
  void initState() {
    super.initState();
    _fetchTotalUsersCount();
    _fetchUsers();
  }

  // --- Data Fetching and Management ---

  /// Fetches the total count of users in the collection.
  Future<void> _fetchTotalUsersCount() async {
    try {
      final aggregateQuery = _firestore.collection(_userCollectionName).count();
      final snapshot = await aggregateQuery.get();
      setState(() {
        _totalUsersCount = snapshot.count ?? 0;
      });
    } catch (e) {
      print('Error fetching total user count: $e');
    }
  }

  /// Builds the base Firestore query with sorting and search logic.
  Query _buildQuery() {
    Query query = _firestore.collection(_userCollectionName);
    query = query.orderBy(_sortField, descending: !_sortAscending);
    return query;
  }

  /// Fetches the initial or next batch of users, or performs a client-side search.
  Future<void> _fetchUsers({bool isInitialLoad = true, bool isNextPage = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isInitialLoad && !isNextPage) {
        _users = [];
        _lastDocument = null;
      }
    });

    try {
      Query baseQuery = _buildQuery();
      QuerySnapshot snapshot;

      if (_currentSearchTerm.isNotEmpty) {
        // Search fix: Fetch the latest 100 users and filter client-side.
        Query searchQuery = _firestore.collection(_userCollectionName)
            .orderBy('createdAt', descending: true) 
            .limit(100); 
        snapshot = await searchQuery.get();
      } else {
        // Server-side pagination when not searching
        baseQuery = baseQuery.limit(_pageSize);
        if (_lastDocument != null && isNextPage) {
          baseQuery = baseQuery.startAfterDocument(_lastDocument!);
        }
        snapshot = await baseQuery.get();
      }

      final List<UserModel> fetchedUsers = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();

      List<UserModel> finalUsers = fetchedUsers;

      if (_currentSearchTerm.isNotEmpty) {
        final searchTermLower = _currentSearchTerm.toLowerCase();
        // Client-side filtering across name, email, and phone
        finalUsers = fetchedUsers.where((user) {
          return user.name.toLowerCase().contains(searchTermLower) ||
              user.email.toLowerCase().contains(searchTermLower) ||
              user.phone.toLowerCase().contains(searchTermLower);
        }).toList();

        setState(() {
          _users = finalUsers;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        if (isInitialLoad && !isNextPage) {
          _users = finalUsers;
        } else {
          _users.addAll(finalUsers);
        }
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        } else {
          _lastDocument = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles the search input change.
  void _onSearchChanged(String value) {
    if (_currentSearchTerm == value.trim()) return;

    setState(() {
      _currentSearchTerm = value.trim();
    });
    _fetchUsers(isInitialLoad: true);
  }

  /// Handles sorting by a column.
  void _onSort(String field) {
    if (_currentSearchTerm.isNotEmpty) return;

    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = (field == 'name' || field == 'email') ? true : false; 
      }
    });
    _fetchUsers(isInitialLoad: true);
  }

  // --- Admin Actions and Dialogs ---

  void _viewUser(UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing detail for: ${user.name}')),
    );
  }

  void _showUserSchemaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Firestore User Schema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Collection: users', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildSchemaRow('avatarLetter', 'String', 'First letter of the user\'s name/display.'),
              _buildSchemaRow('createdAt', 'Timestamp', 'Record creation date and time.'),
              _buildSchemaRow('email', 'String', 'User\'s primary email address (unique).'),
              _buildSchemaRow('name', 'String', 'User\'s full display name.'),
              _buildSchemaRow('phone', 'String', 'User\'s phone number.'),
              _buildSchemaRow('updatedAt', 'Timestamp', 'Last update date and time for the record.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSchemaRow(String field, String type, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(width: 8),
              Text('($type)', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // --- UI Elements ---
  
  Widget _buildTotalUsersCard() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            const Icon(Icons.people, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Users', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  _totalUsersCount.toString(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, email, or phone...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: _currentSearchTerm.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    if (_isLoading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _users.isEmpty) {
      return Center(
        child: Text(
          _currentSearchTerm.isNotEmpty 
            ? 'No users found for "${_currentSearchTerm}"'
            : 'No users available.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        dataRowMaxHeight: 60,
        sortColumnIndex: ['createdAt', 'name', 'email', 'phone', 'updatedAt'].indexOf(_sortField),
        sortAscending: _sortAscending,
        columns: [
          const DataColumn(label: Text('Avatar')),
          DataColumn(
            label: const Text('Name'),
            onSort: (columnIndex, ascending) => _onSort('name'),
          ),
          DataColumn(
            label: const Text('Email'),
            onSort: (columnIndex, ascending) => _onSort('email'),
          ),
          DataColumn(
            label: const Text('Phone'),
            onSort: (columnIndex, ascending) => _onSort('phone'),
          ),
          DataColumn(
            label: const Text('Created At'),
            onSort: (columnIndex, ascending) => _onSort('createdAt'),
          ),
          DataColumn(
            label: const Text('Updated At'),
            onSort: (columnIndex, ascending) => _onSort('updatedAt'),
          ),
          const DataColumn(label: Text('Actions')),
        ],
        rows: _users.map((user) {
          return DataRow(cells: [
            DataCell(
              CircleAvatar(
                backgroundColor: Colors.blueGrey.shade700,
                child: Text(
                  user.avatarLetter.isEmpty ? '?' : user.avatarLetter.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataCell(Text(user.name)),
            DataCell(Text(user.email)),
            DataCell(Text(user.phone)),
            DataCell(
              Text(DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt.toDate())),
            ),
            DataCell(
              Text(DateFormat('yyyy-MM-dd HH:mm').format(user.updatedAt.toDate())),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(message: 'View', child: IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _viewUser(user))),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_currentSearchTerm.isNotEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: null, // Disabled for simplicity
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: (_isLoading || _users.length < _pageSize)
                ? null
                : () => _fetchUsers(isInitialLoad: false, isNextPage: true),
            icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward),
            label: Text(_isLoading ? 'Loading...' : 'Next Page'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Users Management', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Docs Button
          TextButton.icon(
            onPressed: _showUserSchemaDialog,
            icon: const Icon(Icons.description, color: Colors.blue),
            label: const Text('Schema Docs', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            // FIX: Changed 'slivers' to 'sliver' and used SliverList's delegate
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTotalUsersCard(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const Divider(height: 32),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverToBoxAdapter(
              child: _buildUsersTable(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24.0),
            sliver: SliverToBoxAdapter(
              child: _buildPaginationControls(),
            ),
          ),
        ],
      ),
    );
  }
}