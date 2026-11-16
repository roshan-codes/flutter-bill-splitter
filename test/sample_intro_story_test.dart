import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/constants/app_constants.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
    await ActivityRepository.instance.init();
    ActivityRepository.instance.clearActivities();
    await StoryRepository.instance.clearAll();
  });

  group('Sample Intro Story for First-Time Users', () {
    test('First-time user gets one sample story seeded by default on init()',
        () async {
      // 1. Initial state: No stories and sample story not seeded yet
      expect(StoryRepository.instance.stories.isEmpty, isTrue);
      expect(
        await StorageService.instance.getBool(AppConstants.keyHasSeededSampleStory),
        isNot(true),
      );

      // 2. First-time launch init()
      await StoryRepository.instance.init();

      // 3. One sample story was added
      expect(StoryRepository.instance.stories.length, equals(1));
      final sampleStory = StoryRepository.instance.stories.first;
      expect(sampleStory.title, equals('Goa Trip'));
      expect(sampleStory.members.isNotEmpty, isTrue);
      expect(sampleStory.expenses.isNotEmpty, isTrue);

      // 4. Flag was saved in storage
      expect(
        await StorageService.instance.getBool(AppConstants.keyHasSeededSampleStory),
        isTrue,
      );
    });

    test('User can remove the sample story and it is not re-created on next launch',
        () async {
      // 1. Initialize first time
      await StoryRepository.instance.init();
      expect(StoryRepository.instance.stories.length, equals(1));
      final storyId = StoryRepository.instance.stories.first.storyId;

      // 2. User deletes the sample story
      await StoryRepository.instance.deleteStory(storyId);
      expect(StoryRepository.instance.stories.isEmpty, isTrue);

      // 3. User re-opens app (simulated by calling init() again)
      await StoryRepository.instance.init();

      // 4. Sample story is NOT re-created
      expect(StoryRepository.instance.stories.isEmpty, isTrue);
    });
  });
}
