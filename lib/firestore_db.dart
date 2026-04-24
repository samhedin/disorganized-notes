import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirestoreDB {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FixedDateTimeFormatter d = FixedDateTimeFormatter("YYYYMMDDThhmmssZ");

  Future<void> insertNote(Map<String, dynamic> note, String userId,
      String noteId, String? userEmail,
      {bool updateUpdatedAt = true,
      List<Map<dynamic, dynamic>>? reminders}) async {
    final noteWithMetadata = {
      ...note,
      if (!note.containsKey('user_access')) 'user_access': [userId],
      'owner': note.containsKey('owner') ? note['owner'] : userId,
      'user_emails': note.containsKey('user_emails')
          ? note['user_emails']
          : {userId: userEmail},
      if (updateUpdatedAt) 'updated_at': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('notes2')
        .doc(noteId)
        .set(noteWithMetadata);
    if (reminders != null) {
      await uploadReminders(userId, reminders);
    }
  }

  Future<Map<String, dynamic>?> getNoteById(String id) async {
    try {
      DocumentSnapshot doc = await db.collection("notes2").doc(id).get();

      if (!doc.exists) {
        return null;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Handle created_at timestamp consistently with getAllNotes
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate();
      } else {
        data['created_at'] = DateTime.now();
      }

      List<String> userIds = List<String>.from(data['user_access'] ?? []);

      return {
        ...data,
        'id': doc.id,
        'user_access': userIds,
      };
    } catch (e) {
      print("Error getting note by ID (maybe it didn't exist): $e");
      return null;
      // throw Exception('Failed to get note');
    }
  }

 Future<List<Map<String, dynamic>>> getAllNotes(String userId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("notes2")
        .where('user_access', arrayContains: userId)
        .get();
        
    List<Map<String, dynamic>> notes2 =
        await Future.wait(querySnapshot.docs.map((doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Handle created_at timestamp
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate();
      } else {
        data['created_at'] = DateTime.now();
      }
      // Handle updated_at timestamp
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate();
      } else if (data['created_at'] is DateTime || data['created_at'] == null) {
        // If updated_at doesn't exist or is invalid, set it to created_at
        data['updated_at'] = data['created_at'];
      }
      // Ensure updated_at is not earlier than created_at
      if (data['updated_at'] is DateTime &&
          data['created_at'] is DateTime &&
          (data['updated_at'] as DateTime)
              .isBefore(data['created_at'] as DateTime)) {
        data['updated_at'] = data['created_at'];
      }
      // Handle pin value conversion
      if (data['pin'] != null) {
        if (data['pin'] is bool && data['pin'] == true) {
          // Convert boolean true to yesterday's timestamp
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          data['pin'] = Timestamp.fromDate(yesterday);
        } else if (data['pin'] is Timestamp) {
          // Keep existing timestamp
          data['pin'] = data['pin'] as Timestamp;
        } else {
          // Remove invalid pin values
          data.remove('pin');
        }
      }
      Map<String, String?> userEmails =
          Map<String, String?>.from(data['user_emails'] ?? {});
      List<String> userIds = List<String>.from(data['user_access'] ?? []);
      return {
        ...data,
        'id': doc.id,
        'role': data['owner'] == userId ? 'owner' : 'shared',
        'user_emails': userEmails,
      };
    }));
    notes2.sort((a, b) {
      var pinDateA =
          a['pin'] is Timestamp ? (a['pin'] as Timestamp).toDate() : null;
      var pinDateB =
          b['pin'] is Timestamp ? (b['pin'] as Timestamp).toDate() : null;
      // If both notes are pinned, sort by pin date in reverse (oldest first)
      if (pinDateA != null && pinDateB != null) {
        return pinDateA.compareTo(pinDateB);
      }
      // If only one note is pinned, it goes first
      if (pinDateA != null) return -1;
      if (pinDateB != null) return 1;
      // If neither is pinned, sort by created_at (newest first)
      return (b['updated_at'] as DateTime)
          .compareTo(a['updated_at'] as DateTime);
    });
    return notes2;
  } catch (error, stackTrace) {
    // Log to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Error in getAllNotes',
      fatal: false,
    );
    // Re-throw the error or return empty list depending on your error handling strategy
    rethrow;
  }
}

  // Rest of the methods remain unchanged
  Future<String?> getUserIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection("emails")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String? id = querySnapshot.docs.first.id;
        print("Returning user id: $id");
        return id;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user ID by email: $e");
      return null;
    }
  }

  Future<String> shareNote(String noteId, String? userId) async {
    try {
      DocumentReference noteRef = db.collection("notes2").doc(noteId);

      if (userId == null) {
        return "Error sharing note, ensure email is correct. Apple recipients have a proxy email which can be seen in their settings.";
      }

      await noteRef.update({
        'user_access': FieldValue.arrayUnion([userId])
      });

      return "Note shared!";
    } catch (e) {
      print("Error sharing note: $e");
      return "Error sharing note";
    }
  }

  Future<void> setEmail(String email, String userId) async {
    try {
      await db
          .collection("emails")
          .doc(userId)
          .set({'email': email}, SetOptions(merge: true));
    } catch (e) {
      print("Error setting email: $e");
      throw Exception('Failed to set email');
    }
  }

  Future<void> updatePreferences(
      String userId, Map<String, dynamic> opts) async {
    try {
      await db
          .collection("users")
          .doc(userId)
          .set({"preferences": opts}, SetOptions(merge: true));
    } catch (e) {
      print("Error setting preferences: $e");
      throw Exception("Failed to set preferences");
    }
  }

  Map<String, dynamic> ensureStringKeys(Map<dynamic, dynamic> map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  Future<void> uploadReminders(
      String userId, List<Map<dynamic, dynamic>> reminders) async {
    try {
      final userRemindersRef =
          db.collection("reminders").doc(userId).collection("reminders");
      final batch = db.batch();

      for (final reminder in reminders) {
        if (!reminder.containsKey('id') ||
            !reminder.containsKey('datetime') ||
            !reminder.containsKey('description') ||
            !reminder.containsKey('note-id')) {
          print("Skipping invalid reminder: ${reminder.toString()}");
          continue;
        }

        final reminderDoc = userRemindersRef.doc(reminder['id']);
        var noteid = reminder["note-id"];
        batch.set(reminderDoc, {
          "section-id": reminder["section-id"],
          'repeating': reminder['repeating'],
          "timezone": reminder["timezone"],
          'date': reminder['datetime'],
          'description': reminder['description'],
          'note-id': noteid,
          'finished': reminder['finished'],
        });
      }

      await batch.commit();
    } catch (e) {
      print("Error uploading reminders: $e");
      throw Exception("Failed to upload reminders");
    }
  }

  Future<void> deleteReminder(
      String userId, String noteId, String sectionId) async {
    try {
      final remindersRef =
          db.collection("reminders").doc(userId).collection("reminders");

      final querySnapshot =
          await remindersRef.where("section-id", isEqualTo: sectionId).get();

      final batch = db.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print("Reminder for $sectionId deleted");
    } catch (e) {
      print("Error deleting reminders for note $noteId: $e");
      throw Exception("Failed to delete reminder for note");
    }
  }

  Future<void> deleteReminders(String userId, String noteId) async {
    try {
      final remindersRef =
          db.collection("reminders").doc(userId).collection("reminders");

      final querySnapshot =
          await remindersRef.where("note-id", isEqualTo: noteId).get();

      final batch = db.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print("All reminders for note $noteId deleted successfully.");
    } catch (e) {
      print("Error deleting reminders for note $noteId: $e");
      throw Exception("Failed to delete reminders for note");
    }
  }

  Future<Map<String, dynamic>> loadPreferences(String userId) async {
    try {
      final docSnapshot = await db.collection("users").doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['preferences'] as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print("Error loading preferences: $e");
      return {};
    }
  }

  Future<void> deleteNote(String noteId, String userId) async {
    print("DELETING NOTE $noteId");
    try {
      await db.collection("notes2").doc(noteId).delete();
    } catch (e) {
      print("Couldn't delete $noteId");
    }
    await deleteReminders(userId, noteId);
  }
}
