// lib/admin/customers_management.dart
// Responsive Customer Management admin page (Firestore-backed).
// Paste this file into lib/admin/ and import it in admin.dart as shown before.
//
// Requirements:
//  - cloud_firestore in pubspec.yaml
//  - Firebase initialized in your app
//
// Features:
//  - Real-time stream of users
//  - Client-side search + sort + sort order
//  - Responsive: modal dialog on tablet/desktop, full screen bottom sheet on mobile
//  - Edit, Activate/Deactivate, Delete, Export visible CSV

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({Key? key}) : super(key: key);

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // UI state
  String _searchQuery = '';
  String _sortBy = 'createdAt'; // 'createdAt' | 'displayName' | 'lastActive'
  bool _sortDesc = true;
  bool _busy = false;

  // For server-side pagination this can be adapted later.
  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    // Safety: when sort field might be missing in many docs, Firestore will still sort but missing values come first.
    // Limit set to 200 to keep client-side filtering responsive. Increase if needed.
    return _fire
        .collection('users')
        .orderBy(_sortBy, descending: _sortDesc)
        .limit(200)
        .snapshots();
  }

  // Format Timestamp safely
  String _fmtTimestamp(dynamic t) {
    if (t == null) return '-';
    if (t is Timestamp) {
      final dt = t.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return t.toString();
  }

  // Client-side filter for small/medium user sets
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterDocs(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String q) {
    if (q.trim().isEmpty) return docs;
    final ql = q.toLowerCase();
    return docs.where((d) {
      final data = d.data();
      final name = (data['displayName'] ?? data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final phone = (data['phone'] ?? '').toString().toLowerCase();
      return name.contains(ql) || email.contains(ql) || phone.contains(ql);
    }).toList();
  }

  // Export visible docs to CSV (copies to clipboard)
  Future<void> _exportCsv(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final header = 'uid,displayName,email,phone,role,active,createdAt,lastActive';
    final rows = docs.map((d) {
      final data = d.data();
      final uid = d.id;
      final name = (data['displayName'] ?? '').toString().replaceAll(',', ' ');
      final email = (data['email'] ?? '').toString();
      final phone = (data['phone'] ?? '').toString();
      final role = (data['role'] ?? '').toString();
      final active = (data['active'] ?? true).toString();
      final createdAt = _fmtTimestamp(data['createdAt']);
      final lastActive = _fmtTimestamp(data['lastActive']);
      return '$uid,$name,$email,$phone,$role,$active,$createdAt,$lastActive';
    }).join('\n');

    final csv = '$header\n$rows';
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
    }
  }

  // Toggle active state with confirmation
  Future<void> _toggleActive(String uid, bool current) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(current ? 'Deactivate user?' : 'Reactivate user?'),
          content: Text(current
              ? 'This will prevent the user from logging in. Logs will remain.'
              : 'This will reactivate the account and allow the user to sign in.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
          ],
        );
      },
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await _fire.collection('users').doc(uid).update({'active': !current});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${!current ? 're-activated' : 'deactivated'}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Delete user with strong confirmation
  Future<void> _deleteUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user permanently?'),
        content: const Text('This will permanently delete the user record from Firestore. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await _fire.collection('users').doc(uid).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Open the edit UI: dialog on large screens, bottom sheet full-screen on mobile
  Future<void> _openUserEditor(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final uid = doc.id;
    final nameController = TextEditingController(text: (data['displayName'] ?? '').toString());
    final emailController = TextEditingController(text: (data['email'] ?? '').toString());
    final phoneController = TextEditingController(text: (data['phone'] ?? '').toString());
    String role = (data['role'] ?? 'customer').toString();
    bool active = (data['active'] ?? true) as bool;

    final isMobile = MediaQuery.of(context).size.width < 700;

    Future<bool?> saveChanges() async {
      setState(() => _busy = true);
      try {
        await _fire.collection('users').doc(uid).update({
          'displayName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': role,
          'active': active,
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated')));
        return true;
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        return false;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }

    if (isMobile) {
      // full screen bottom sheet for mobile
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: StatefulBuilder(builder: (context, setSt) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text('Edit: ${nameController.text.isEmpty ? uid : nameController.text}'),
                        actions: [
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: 'Name'),
                                onChanged: (_) => setSt(() {}),
                              ),
                              const SizedBox(height: 8),
                              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                              const SizedBox(height: 8),
                              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Text('Role:'),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: role,
                                  items: const [
                                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                                    DropdownMenuItem(value: 'vip', child: Text('VIP')),
                                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                  ],
                                  onChanged: (v) => setSt(() => role = v ?? 'customer'),
                                ),
                                const Spacer(),
                                const Text('Active:'),
                                Switch(value: active, onChanged: (v) => setSt(() => active = v)),
                              ]),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _busy ? null : () async {
                                        final ok = await saveChanges();
                                        if (ok == true && mounted) Navigator.pop(context);
                                      },
                                      child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _busy ? null : () => _toggleActive(uid, active),
                                      child: Text(active ? 'Deactivate' : 'Reactivate'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: _busy ? null : () async {
                                        Navigator.pop(context); // close sheet first
                                        await _deleteUser(uid);
                                      },
                                      child: const Text('Delete (permanent)'),
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
              }),
            ),
          );
        },
      );
    } else {
      // desktop/tablet dialog
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setSt) {
            return AlertDialog(
              title: Text('Edit user: ${nameController.text.isEmpty ? uid : nameController.text}'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 8),
                      TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                      const SizedBox(height: 8),
                      TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('Role:'),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: role,
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text('Customer')),
                            DropdownMenuItem(value: 'vip', child: Text('VIP')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (v) => setSt(() => role = v ?? 'customer'),
                        ),
                        const Spacer(),
                        const Text('Active:'),
                        Switch(value: active, onChanged: (v) => setSt(() => active = v)),
                      ])
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                OutlinedButton(onPressed: _busy ? null : () => _toggleActive(uid, active), child: Text(active ? 'Deactivate' : 'Reactivate')),
                ElevatedButton(
                  onPressed: _busy ? null : () async {
                    final saved = await saveChanges();
                    if (saved == true && mounted) Navigator.pop(context);
                  },
                  child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                ),
                TextButton(
                  onPressed: _busy ? null : () async {
                    Navigator.pop(context);
                    await _deleteUser(uid);
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                )
              ],
            );
          });
        },
      );
    }
  }

  // UI building
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            tooltip: 'Export visible results to CSV',
            onPressed: () async {
              final snap = await _usersStream().first;
              final docs = _filterDocs(snap.docs, _searchQuery);
              await _exportCsv(docs);
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + sort controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name, email or phone'),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'createdAt', child: Text('Created date')),
                      DropdownMenuItem(value: 'displayName', child: Text('Name')),
                      DropdownMenuItem(value: 'lastActive', child: Text('Last active')),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v ?? 'createdAt'),
                  ),
                ),
                IconButton(
                  tooltip: 'Toggle sort order',
                  onPressed: () => setState(() => _sortDesc = !_sortDesc),
                  icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
                )
              ],
            ),
          ),

          // Stream list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _usersStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final filtered = _filterDocs(docs, _searchQuery);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                // Mobile: denser cards; Desktop: larger list tiles
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final d = filtered[i];
                    final data = d.data();
                    final uid = d.id;
                    final name = (data['displayName'] ?? data['name'] ?? '').toString();
                    final email = (data['email'] ?? '—').toString();
                    final phone = (data['phone'] ?? '—').toString();
                    final role = (data['role'] ?? 'customer').toString();
                    final active = (data['active'] ?? true) as bool;
                    final created = _fmtTimestamp(data['createdAt']);
                    final lastActive = _fmtTimestamp(data['lastActive']);

                    if (isMobile) {
                      // Card-friendly mobile row
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          onTap: () => _openUserEditor(d),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 24, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(name.isEmpty ? uid : name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(email, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Row(children: [Text('Role: $role', style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(width: 8), Text('Last: $lastActive', style: const TextStyle(fontSize: 12, color: Colors.black54))])
                                  ]),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(active ? Icons.block : Icons.check_circle, color: active ? Colors.red : Colors.green),
                                      onPressed: _busy ? null : () => _toggleActive(uid, active),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever, color: Colors.grey),
                                      onPressed: _busy ? null : () => _deleteUser(uid),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Desktop / tablet ListTile
                      return Card(
                        child: ListTile(
                          onTap: () => _openUserEditor(d),
                          leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                          title: Text(name.isEmpty ? uid : name),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(email),
                            const SizedBox(height: 6),
                            Row(children: [Text('Role: $role', style: const TextStyle(fontSize: 12)), const SizedBox(width: 12), Text('Created: $created', style: const TextStyle(fontSize: 12)), const SizedBox(width: 12), Text('Last: $lastActive', style: const TextStyle(fontSize: 12))])
                          ]),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: active ? 'Deactivate' : 'Reactivate',
                                  icon: Icon(active ? Icons.block : Icons.check_circle, color: active ? Colors.red : Colors.green),
                                  onPressed: _busy ? null : () => _toggleActive(uid, active),
                                ),
                                IconButton(
                                  tooltip: 'Delete (permanent)',
                                  icon: const Icon(Icons.delete_forever, color: Colors.grey),
                                  onPressed: _busy ? null : () => _deleteUser(uid),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'view') {
                                      _openUserEditor(d);
                                    } else if (v == 'copyid') {
                                      await Clipboard.setData(ClipboardData(text: uid));
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UID copied')));
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'view', child: Text('View / Edit')),
                                    PopupMenuItem(value: 'copyid', child: Text('Copy UID')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
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
