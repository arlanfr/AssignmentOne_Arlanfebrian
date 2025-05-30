import 'package:firebase_database/firebase_database.dart';

class RemoteDataSource {
  Future<bool> checkAuthStatus({required String userPasssword}) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance
              .ref('users')
              .child('h8_student_01')
              .child('password')
              .get();

      if (snapshot.exists) {
        final password = snapshot.value as String?;
        return password != null && password == userPasssword;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error on checkAuthStatus: $e');
    }
  }
}
