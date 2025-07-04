import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useNotes } from '../context/NotesContext';
import EditNoteModal from './EditNoteModal';

export default function NoteItem({ note }) {
  const [editModalVisible, setEditModalVisible] = useState(false);
  const { deleteNote } = useNotes();

  const handleDelete = () => {
    Alert.alert(
      'Delete Note',
      'Are you sure you want to delete this note?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => deleteNote(note.id) }
      ]
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.text}>{note.text}</Text>
      <View style={styles.actions}>
        <TouchableOpacity
          style={styles.deleteButton}
          onPress={handleDelete}
        >
          <Text style={styles.deleteText}>🗑</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.editButton}
          onPress={() => setEditModalVisible(true)}
        >
          <Text style={styles.editText}>✏️</Text>
        </TouchableOpacity>
      </View>
      
      <EditNoteModal
        visible={editModalVisible}
        onClose={() => setEditModalVisible(false)}
        note={note}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f8f9fa',
    padding: 15,
    marginBottom: 10,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#007bff',
  },
  text: {
    fontSize: 16,
    marginBottom: 10,
    flex: 1,
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  deleteButton: {
    marginLeft: 10,
  },
  editButton: {
    marginLeft: 10,
  },
  deleteText: {
    fontSize: 18,
  },
  editText: {
    fontSize: 18,
  },
});
