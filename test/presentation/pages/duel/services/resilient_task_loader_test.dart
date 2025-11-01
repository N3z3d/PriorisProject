import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';

class _StubLoggerService extends LoggerService {
  _StubLoggerService() : super.testing(Logger());
}

Task _buildTask(String id) {
  return Task(
    id: id,
    title: 'Task $id',
    eloScore: 1200,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('ResilientTaskLoader', () {
    late List<Task> sampleTasks;

    setUp(() {
      sampleTasks = [
        _buildTask('a'),
        _buildTask('b'),
        _buildTask('c'),
      ];
    });

    test('returns fresh tasks and caches them on success', () async {
      var callCount = 0;
      final loader = ResilientTaskLoader(
        loadTasks: () async {
          callCount += 1;
          return sampleTasks;
        },
        logger: _StubLoggerService(),
        retries: 0,
      );

      final result = await loader.load();

      expect(
        result.map((task) => task.id).toList(),
        sampleTasks.map((task) => task.id).toList(),
      );
      expect(
        loader.lastSuccessfulTasks.map((task) => task.id).toList(),
        sampleTasks.map((task) => task.id).toList(),
      );
      expect(callCount, 1);
    });

    test('retries before falling back to cache', () async {
      final calls = <int>[];
      final loader = ResilientTaskLoader(
        loadTasks: () async {
          calls.add(calls.length);
          if (calls.length < 3) {
            throw Exception('network issue');
          }
          return sampleTasks;
        },
        logger: _StubLoggerService(),
        retries: 2,
        delayBuilder: (_) => Duration.zero,
      );

      final result = await loader.load();

      expect(
        result.map((task) => task.id).toList(),
        sampleTasks.map((task) => task.id).toList(),
      );
      expect(
        loader.lastSuccessfulTasks.map((task) => task.id).toList(),
        sampleTasks.map((task) => task.id).toList(),
      );
      expect(calls.length, 3);
    });

    test('uses cached tasks when all retries fail', () async {
      var calls = 0;
      final loader = ResilientTaskLoader(
        loadTasks: () async {
          calls += 1;
          if (calls == 1) {
            return sampleTasks;
          }
          throw Exception('network issue');
        },
        logger: _StubLoggerService(),
        retries: 1,
        delayBuilder: (_) => Duration.zero,
      );

      await loader.load(); // seed cache
      final result = await loader.load();

      expect(result, sampleTasks);
      expect(
        loader.lastSuccessfulTasks.map((task) => task.id).toList(),
        sampleTasks.map((task) => task.id).toList(),
      );
      expect(calls, 3);
    });

    test('throws DuelLoadingException when no cache is available', () async {
      final loader = ResilientTaskLoader(
        loadTasks: () async {
          throw Exception('network issue');
        },
        logger: _StubLoggerService(),
        retries: 1,
        delayBuilder: (_) => Duration.zero,
      );

      expect(
        () => loader.load(),
        throwsA(isA<DuelLoadingException>()),
      );
    });
  });
}
