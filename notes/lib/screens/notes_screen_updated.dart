import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = context.read<NotesProvider>();
      notesProvider.fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirmed = await _showLogoutDialog(context);
              if (confirmed && mounted) {
                context.read<AuthProvider>().signOut();
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            // Show error message if there's an error
            if (notesProvider.lastError != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showSnackBar(context, notesProvider.lastError!, isError: true);
                notesProvider.clearError();
              });
            }

            if (notesProvider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your notes...'),
                  ],
                ),
              );
            }

            if (notesProvider.notes.isEmpty) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isWideScreen = screenWidth > 600;

              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 40 : 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: isWideScreen ? 100 : 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: isWideScreen ? 24 : 16),
                      Text(
                        'Nothing here yet—tap ➕ to add a note.',
                        style: TextStyle(
                          fontSize: isWideScreen ? 20 : 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWideScreen ? 32 : 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddNoteDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add Your First Note',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWideScreen ? 16 : 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: EdgeInsets.symmetric(
                            horizontal: isWideScreen ? 32 : 24,
                            vertical: isWideScreen ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => notesProvider.fetchNotes(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Check if we're in landscape mode or have wide screen
                  final isWideScreen = constraints.maxWidth > 600;
                  final crossAxisCount = isWideScreen ? 2 : 1;

                  if (isWideScreen) {
                    // Grid layout for wide screens
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5, // Adjust card height
                      ),
                      itemCount: notesProvider.notes.length,
                      itemBuilder: (context, index) {
                        final note = notesProvider.notes[index];
                        return _buildNoteCard(context, note);
                      },
                    );
                  } else {
                    // List layout for narrow screens
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notesProvider.notes.length,
                      itemBuilder: (context, index) {
                        final note = notesProvider.notes[index];
                        return _buildNoteCard(context, note);
                      },
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isWideScreen = screenWidth > 600;

          return FloatingActionButton(
            onPressed: () => _showAddNoteDialog(context),
            backgroundColor: Colors.green.shade600,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: isWideScreen ? 28 : 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Card(
      margin: EdgeInsets.only(
        bottom: isWideScreen ? 8 : 12,
      ),
      elevation: 3,
      shadowColor: Colors.green.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.green.shade200, width: 0.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: TextStyle(
                        fontSize: isWideScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.green.shade600,
                      size: isWideScreen ? 20 : 24,
                    ),
                    onPressed: () => _showEditNoteDialog(context, note),
                    tooltip: 'Edit note',
                    constraints: BoxConstraints(
                      minWidth: isWideScreen ? 32 : 40,
                      minHeight: isWideScreen ? 32 : 40,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isWideScreen ? 20 : 24,
                    ),
                    onPressed: () => _showDeleteConfirmation(context, note),
                    tooltip: 'Delete note',
                    constraints: BoxConstraints(
                      minWidth: isWideScreen ? 32 : 40,
                      minHeight: isWideScreen ? 32 : 40,
                    ),
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                SizedBox(height: isWideScreen ? 4 : 8),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: isWideScreen ? 14 : 16,
                    color: Colors.black87,
                  ),
                  maxLines: isWideScreen ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: isWideScreen ? 8 : 12),
              Text(
                'Created: ${_formatDate(note.createdAt)}',
                style: TextStyle(
                  fontSize: isWideScreen ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
              if (note.updatedAt != note.createdAt)
                Text(
                  'Updated: ${_formatDate(note.updatedAt)}',
                  style: TextStyle(
                    fontSize: isWideScreen ? 10 : 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddNoteDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Note'),
        content: SizedBox(
          width: isWideScreen ? 500 : screenWidth * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: isWideScreen ? 6 : 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty && content.isEmpty) {
                _showSnackBar(context, 'Please enter some content',
                    isError: true);
                return;
              }

              Navigator.pop(context);

              final success =
                  await context.read<NotesProvider>().addNote(title, content);

              if (mounted) {
                if (success) {
                  _showSnackBar(context, 'Note added successfully!');
                } else {
                  final error = context.read<NotesProvider>().lastError;
                  _showSnackBar(context, error ?? 'Failed to add note',
                      isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNoteDialog(BuildContext context, Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: SizedBox(
          width: isWideScreen ? 500 : screenWidth * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: isWideScreen ? 6 : 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty && content.isEmpty) {
                _showSnackBar(context, 'Please enter some content',
                    isError: true);
                return;
              }

              Navigator.pop(context);

              final success = await context
                  .read<NotesProvider>()
                  .updateNote(note.id, title, content);

              if (mounted) {
                if (success) {
                  _showSnackBar(context, 'Note updated successfully!');
                } else {
                  final error = context.read<NotesProvider>().lastError;
                  _showSnackBar(context, error ?? 'Failed to update note',
                      isError: true);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Note note) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
          'Are you sure you want to delete "${note.title.isEmpty ? 'Untitled' : note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final success =
                  await context.read<NotesProvider>().deleteNote(note.id);

              if (mounted) {
                if (success) {
                  _showSnackBar(context, 'Note deleted successfully!');
                } else {
                  final error = context.read<NotesProvider>().lastError;
                  _showSnackBar(context, error ?? 'Failed to delete note',
                      isError: true);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
