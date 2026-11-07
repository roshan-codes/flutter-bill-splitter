import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService.instance;
      await storageService.init();
    });

    test('setString and getString persists and retrieves string', () async {
      final success = await storageService.setString('test_key', 'hello_world');
      expect(success, isTrue);

      final result = await storageService.getString('test_key');
      expect(result, 'hello_world');
    });

    test('setStringList and getStringList persists and retrieves list', () async {
      final list = ['item1', 'item2', 'item3'];
      final success = await storageService.setStringList('list_key', list);
      expect(success, isTrue);

      final result = await storageService.getStringList('list_key');
      expect(result, list);
    });

    test('remove removes the specified key', () async {
      await storageService.setString('key_to_delete', 'val');
      expect(await storageService.getString('key_to_delete'), 'val');

      await storageService.remove('key_to_delete');
      expect(await storageService.getString('key_to_delete'), isNull);
    });

    test('clear removes all keys', () async {
      await storageService.setString('key1', 'val1');
      await storageService.setString('key2', 'val2');

      await storageService.clear();
      expect(await storageService.getString('key1'), isNull);
      expect(await storageService.getString('key2'), isNull);
    });
  });
}

