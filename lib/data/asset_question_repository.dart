import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/question.dart';
import '../domain/question_bank.dart';
import '../domain/question_repository.dart';

/// Đọc ngân hàng câu hỏi từ tệp JSON đóng gói trong assets.
class AssetQuestionRepository implements QuestionRepository {
  AssetQuestionRepository({AssetBundle? bundle, this.assetPath = defaultAssetPath})
      : _bundle = bundle ?? rootBundle;

  static const defaultAssetPath = 'assets/data/questions.json';

  final AssetBundle _bundle;
  final String assetPath;

  @override
  Future<QuestionBank> load() async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('questions.json phải là một mảng JSON');
    }
    return QuestionBank(
      decoded.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
