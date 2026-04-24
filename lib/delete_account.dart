import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_db.dart';

class DeleteAccount {
  final FirebaseAuth firebaseAuth;
  final FirestoreDB firestoreDB;

  DeleteAccount({FirebaseAuth? auth, FirestoreDB? db})
      : firebaseAuth = auth ?? FirebaseAuth.instance,
        firestoreDB = db ?? FirestoreDB();

  Future<void> deleteUserAccount(List<String> noteIds, String userId,
      {String? email, String? password}) async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Skip reauthentication if the user is anonymous
      if (!user.isAnonymous) {
        final providerData = user.providerData.first;

        switch (providerData.providerId) {
          case 'apple.com':
            await user.reauthenticateWithProvider(AppleAuthProvider());
            break;

          case 'google.com':
            await user.reauthenticateWithProvider(GoogleAuthProvider());
            break;

          case 'password':
            if (email == null || password == null) {
              throw Exception('Email authentication requires email and password. '
                  'Please provide both email and password when calling deleteUserAccount().');
            }

            final credential = EmailAuthProvider.credential(
                email: email, password: password);
            await user.reauthenticateWithCredential(credential);
            break;

          default:
            throw Exception('Unsupported provider: ${providerData.providerId}');
        }
      }

      // Delete all notes
      for (final noteId in noteIds) {
        await firestoreDB.deleteNote(noteId, userId);
      }

      // Delete user account
      await user.delete();
    } catch (e) {
      debugPrint('Reauthentication Exception: $e');
      throw Exception('Failed to delete account: $e');
    }
  }
}
