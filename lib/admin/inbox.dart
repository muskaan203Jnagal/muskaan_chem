// ============================================================================
// lib/admin/inbox.dart (UPDATED)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- Models and Enums ---

/// Enum representing the subject categories for a contact submission.
enum ContactSubject {
  generalInquiry,
  suggestions,
  product,
  other,
}

/// Utility extension to convert the enum to a user-friendly string.
extension ContactSubjectExtension on ContactSubject {
  String toTitleString() {
    switch (this) {
      case ContactSubject.generalInquiry:
        return 'General Inquiry';
      case ContactSubject.suggestions:
        return 'Suggestions';
      case ContactSubject.product:
        return 'Product';
      case ContactSubject.other:
        return 'Other';
    }
  }
}

// --- Inbox Page ---

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  // State for filtering
  ContactSubject? _selectedSubjectFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  // Firestore reference (assumes collection is named 'contactSubmissions')
  final CollectionReference _submissionsCollection =
      FirebaseFirestore.instance.collection('contactSubmissions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Lighter background
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(context),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Recent Submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            child: _buildSubmissionList(),
          ),
        ],
      ),
    );
  }

  /// Builds the AppBar with title, Add Submission button, and Docs button.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Inbox Management'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      actions: [
        // Docs Button
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Database Schema',
          onPressed: () => _showSchemaDialog(context),
        ),
        // Add Custom Submission Button
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddSubmissionDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Custom'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the filtering UI.
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Subject Filter
          const Text('Subject:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ContactSubject>(
                value: _selectedSubjectFilter,
                hint: const Text('All'),
                onChanged: (ContactSubject? newValue) {
                  setState(() {
                    _selectedSubjectFilter = newValue;
                  });
                },
                items: [
                  const DropdownMenuItem<ContactSubject>(
                    value: null,
                    child: Text('All Subjects'),
                  ),
                  ...ContactSubject.values.map((subject) {
                    return DropdownMenuItem<ContactSubject>(
                      value: subject,
                      child: Text(subject.toTitleString()),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),
          // Date Range Filter
          const Text('Date Range:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          _buildDateFilterButton(context, isStart: true),
          const SizedBox(width: 8),
          const Text('to'),
          const SizedBox(width: 8),
          _buildDateFilterButton(context, isStart: false),

          const SizedBox(width: 20),
          // Clear Filters Button
          if (_selectedSubjectFilter != null || _startDateFilter != null || _endDateFilter != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedSubjectFilter = null;
                  _startDateFilter = null;
                  _endDateFilter = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildDateFilterButton(BuildContext context, {required bool isStart}) {
    DateTime? currentDate = isStart ? _startDateFilter : _endDateFilter;
    String label = isStart ? 'Start Date' : 'End Date';
    String display = currentDate == null ? label : DateFormat('MMM dd, yyyy').format(currentDate);

    return OutlinedButton.icon(
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: currentDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (pickedDate != null) {
          setState(() {
            if (isStart) {
              _startDateFilter = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
            } else {
              // Set end date to the very end of the selected day for inclusive filtering
              _endDateFilter = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 23, 59, 59, 999);
            }
          });
        }
      },
      icon: Icon(currentDate == null ? Icons.calendar_today : Icons.edit, size: 18),
      label: Text(display),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  /// Builds the main list of submissions using a StreamBuilder with client-side filtering.
  Widget _buildSubmissionList() {
    // 1. SIMPLIFIED FIRESTORE QUERY: Fetch all data, only sorting by timestamp.
    Query query = _submissionsCollection.orderBy('timestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> submissions = snapshot.data!.docs;

        // 2. CLIENT-SIDE FILTERING: Apply filters to the fetched list.
        List<DocumentSnapshot> filteredSubmissions = submissions.where((document) {
          final data = document.data()! as Map<String, dynamic>;
          final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          final DateTime date = timestamp.toDate();
          final String subject = data['subject'] as String? ?? 'other';

          // Subject Filter
          bool subjectMatch = _selectedSubjectFilter == null || subject == _selectedSubjectFilter!.name;

          // Date Range Filter
          bool dateMatch = true;
          if (_startDateFilter != null) {
            dateMatch = dateMatch && date.isAfter(_startDateFilter!) || date.isAtSameMomentAs(_startDateFilter!);
          }
          if (_endDateFilter != null) {
            dateMatch = dateMatch && date.isBefore(_endDateFilter!) || date.isAtSameMomentAs(_endDateFilter!);
          }

          return subjectMatch && dateMatch;
        }).toList();

        if (filteredSubmissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Submissions Match Filters',
                  style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredSubmissions.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = filteredSubmissions[index];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return _buildSubmissionCard(data, document.id);
          },
        );
      },
    );
  }

  /// Builds a card for a single submission (Improved UI).
  Widget _buildSubmissionCard(Map<String, dynamic> data, String docId) {
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    DateTime date = timestamp.toDate();
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    String subjectText = (data['subject'] as String? ?? 'other');
    String subjectTitle = ContactSubject.values.firstWhere(
      (e) => e.name == subjectText,
      orElse: () => ContactSubject.other,
    ).toTitleString();
    
    // Determine the color for the subject pill
    Color subjectColor;
    switch (subjectText) {
      case 'generalInquiry':
        subjectColor = Colors.lightBlue.shade100;
        break;
      case 'suggestions':
        subjectColor = Colors.green.shade100;
        break;
      case 'product':
        subjectColor = Colors.purple.shade100;
        break;
      default:
        subjectColor = Colors.orange.shade100;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showSubmissionDetails(context, data, docId),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Subject
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subjectColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      subjectTitle,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['email'] ?? 'N/A',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Phone: ${data['phone'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Message: ${data['message'] ?? 'No message provided.'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Date and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Submission',
                    onPressed: () => _deleteSubmission(docId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Dialog to show the database schema.
  void _showSchemaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('📬 Inbox Database Schema'),
          content: const SingleChildScrollView(
            child: Text(
              'Collection: contactSubmissions\n\n'
              'Fields:\n'
              '1. firstName (string): User\'s first name.\n'
              '2. lastName (string): User\'s last name.\n'
              '3. email (string): User\'s email address.\n'
              '4. phone (string): User\'s phone number.\n'
              '5. subject (string): The subject chosen (e.g., \'generalInquiry\', \'suggestions\').\n'
              '6. message (string): The body of the message.\n'
              '7. timestamp (Timestamp): Server timestamp of submission (for sorting/filtering).\n'
              '8. isRead (bool, optional): To track if the admin has viewed it (default: false).\n'
            ),
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

  /// Dialog to add a custom submission.
  void _showAddSubmissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddSubmissionDialog(
          onSubmit: (data) async {
            await _submissionsCollection.add({
              ...data,
              'timestamp': FieldValue.serverTimestamp(),
            });
            // Optionally, show a snackbar confirmation
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custom submission added!')),
              );
            }
          },
        );
      },
    );
  }

  /// Dialog to show full submission details.
  void _showSubmissionDetails(BuildContext context, Map<String, dynamic> data, String docId) {
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    DateTime date = timestamp.toDate();
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    String subjectText = (data['subject'] as String? ?? 'other');
    String subjectTitle = ContactSubject.values.firstWhere(
      (e) => e.name == subjectText,
      orElse: () => ContactSubject.other,
    ).toTitleString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Submission from ${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Date', formattedDate),
                _detailRow('Subject', subjectTitle),
                _detailRow('Email', data['email'] ?? 'N/A'),
                _detailRow('Phone', data['phone'] ?? 'N/A'),
                const Divider(),
                const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data['message'] ?? 'No message provided.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close details dialog
                _deleteSubmission(docId, shouldPop: false); // Call delete
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Function to delete a submission from Firestore.
  void _deleteSubmission(String docId, {bool shouldPop = true}) async {
    await _submissionsCollection.doc(docId).delete();
    if (shouldPop) Navigator.of(context).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission deleted.')),
      );
    }
  }
}

// --- Add Submission Dialog Widget (Unchanged) ---

typedef SubmissionCallback = void Function(Map<String, dynamic> data);

class AddSubmissionDialog extends StatefulWidget {
  final SubmissionCallback onSubmit;

  const AddSubmissionDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AddSubmissionDialog> createState() => _AddSubmissionDialogState();
}

class _AddSubmissionDialogState extends State<AddSubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  ContactSubject _selectedSubject = ContactSubject.generalInquiry;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'subject': _selectedSubject.name, // Storing enum name as string
        'message': _messageController.text.trim(),
        // timestamp will be added by the caller (InboxPage)
      };
      widget.onSubmit(data);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Add Custom Submission'),
      content: SizedBox(
        width: 600, // Make the dialog wider for the form
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name fields
                Row(
                  children: [
                    Expanded(child: _buildTextField('First Name', _firstNameController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField('Last Name', _lastNameController)),
                  ],
                ),
                _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress, validator: _emailValidator),
                _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone),

                // Subject Radio Buttons
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Text('Select Subject:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...ContactSubject.values.map((subject) => RadioListTile<ContactSubject>(
                      title: Text(subject.toTitleString()),
                      value: subject,
                      groupValue: _selectedSubject,
                      onChanged: (ContactSubject? value) {
                        setState(() {
                          _selectedSubject = value!;
                        });
                      },
                    )),

                // Message field
                _buildTextField('Message', _messageController, maxLines: 5),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save Submission'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // Simple regex for email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}