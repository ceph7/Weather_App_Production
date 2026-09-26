import 'dart:io';

import 'package:hive/hive.dart';

/// Initialise Hive dans un répertoire temporaire pour les tests unitaires
/// qui touchent au stockage local (favorites, history...).
///
/// Chaque appel à [setUpHiveForTest] crée un nouveau dossier temporaire ;
/// pense à appeler [tearDownHiveForTest] dans un `tearDown` pour nettoyer.
class HiveTestHelper {
  static Directory? _tempDir;

  static Future<void> setUp() async {
    _tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(_tempDir!.path);
  }

  static Future<void> tearDown() async {
    await Hive.deleteFromDisk();
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
    }
    _tempDir = null;
  }
}
