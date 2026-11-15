import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';

void main() {
  group('AvatarResolver Gender-Aware Memo Assignment', () {
    test('Resolves female names to female memo avatars', () {
      final femaleNames = ['Kaavya', 'Gunjan', 'Sharda', 'Priya', 'Ananya', 'Sneha', 'Neha'];
      for (final name in femaleNames) {
        final isFemale = AvatarResolver.isFemaleName(name);
        expect(isFemale, isTrue, reason: '$name should be identified as female');

        final index = AvatarResolver.getDefaultAvatarIndexForName(name);
        expect(AvatarResolver.femaleMemoIndices.contains(index), isTrue,
            reason: '$name avatar index $index should be in female pool');

        final path = AvatarResolver.getDefaultAvatarForName(name);
        expect(path, equals('assets/avatars/memo_$index.png'));
      }
    });

    test('Resolves male names to male memo avatars', () {
      final maleNames = ['Roshan', 'Rahul', 'Amit', 'Sachin', 'Gaurav', 'Vivek', 'Kunal'];
      for (final name in maleNames) {
        final isFemale = AvatarResolver.isFemaleName(name);
        expect(isFemale, isFalse, reason: '$name should be identified as male');

        final index = AvatarResolver.getDefaultAvatarIndexForName(name);
        expect(AvatarResolver.maleMemoIndices.contains(index), isTrue,
            reason: '$name avatar index $index should be in male pool');

        final path = AvatarResolver.getDefaultAvatarForName(name);
        expect(path, equals('assets/avatars/memo_$index.png'));
      }
    });

    test('Handles names with (You) suffix transparently', () {
      expect(AvatarResolver.isFemaleName('Kaavya (You)'), isTrue);
      expect(AvatarResolver.isFemaleName('Gunjan (You)'), isTrue);
      expect(AvatarResolver.isFemaleName('Roshan Badwaik (You)'), isFalse);
    });

    test('Deterministic: same name produces identical avatar every time', () {
      final first = AvatarResolver.getDefaultAvatarForName('Kaavya');
      final second = AvatarResolver.getDefaultAvatarForName('Kaavya');
      expect(first, equals(second));

      final r1 = AvatarResolver.getDefaultAvatarForName('Roshan');
      final r2 = AvatarResolver.getDefaultAvatarForName('Roshan');
      expect(r1, equals(r2));
    });
  });
}
