import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('suy ra danh sách khối đã sắp xếp và đếm số câu', () {
    final bank = sampleBank();
    expect(bank.blocks.map((b) => b.id), [1, 2]);
    expect(bank.blocks.map((b) => b.questionCount), [2, 1]);
  });

  test('inBlock chỉ trả các câu của khối đó', () {
    final bank = sampleBank();
    expect(bank.inBlock(1).map((q) => q.id), [1, 2]);
    expect(bank.inBlock(99), isEmpty);
  });
}
