import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class EncryptedDBOperations {
  // apply "Singleton" pattern to guarantee a single instance is made
  static final EncryptedDBOperations instance = EncryptedDBOperations._internal();

  // Secure NoSQL database
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Used to encrypt and decrypt using the AES key and initialization vector
  late final Encrypter _encrypter;
  late final IV _iv;

  // Initialization constructor
  EncryptedDBOperations._internal() {
    // final key = Key.fromUtf8(dotenv.env['AES_KEY']!);
    final key = Key.fromUtf8("Y0uW0u1DN0783L13V3H0W53CUr37H1S1");
    _iv = IV.fromLength(16); // You may replace this with your fixed IV
    _encrypter = Encrypter(AES(key));
  }

  // Encrypt and store task using a unique ID, same method can be used for saving and updating
  Future<void> saveTask(Task task) async {
    final String id = task.id?.toString() ?? const Uuid().v4();
    final plainText = jsonEncode(task.toMap());
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    await _secureStorage.write(key: id, value: encrypted.base64);
  }

  // Load and decrypt all tasks
  Future<List<Task>> getTasks({String sortBy = 'dueDate'}) async {
    final all = await _secureStorage.readAll();
    List<Task> decryptedTasks = [];

    for (final entry in all.entries) {
      try {
        final encrypted = Encrypted.fromBase64(entry.value);
        final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
        final map = jsonDecode(decrypted);
        decryptedTasks.add(Task.fromMap(map));
      } catch (e) {
        // Skip malformed or non-task entries
        continue;
      }
    }

    // Sorting based on passed sorting type
    decryptedTasks.sort((a, b) {
      if (sortBy == 'priority') {
        return b.priority.compareTo(a.priority);
      } else {
        return a.dueDate.compareTo(b.dueDate); // Assumes ISO date strings
      }
    });

    return decryptedTasks;
  }

  // Delete encrypted task by ID
  Future<void> deleteTask(String id) async {
    await _secureStorage.delete(key: id);
  }
}
