import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

typedef SupabaseQueryBuilderCallback = dynamic Function(dynamic query);

class SupabaseTableAdapter {
  SupabaseTableAdapter(this._base);

  final dynamic _base;

  Future<List<Map<String, dynamic>>> select({
    String columns = '*',
    SupabaseQueryBuilderCallback? builder,
  }) async {
    dynamic query = _base.select(columns);
    query = _applyBuilder(query, builder);
    final result = await query;
    return (result as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> selectSingle({
    String columns = '*',
    SupabaseQueryBuilderCallback? builder,
  }) async {
    dynamic query = _base.select(columns);
    query = _applyBuilder(query, builder);
    final dynamic data = await query.maybeSingle();
    if (data == null) {
      return null;
    }
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> insert(Map<String, dynamic> values) async {
    await _base.insert(values);
  }

  Future<void> update({
    required Map<String, dynamic> values,
    SupabaseQueryBuilderCallback? builder,
  }) async {
    dynamic query = _base.update(values);
    query = _applyBuilder(query, builder);
    await query;
  }

  Future<void> delete({
    SupabaseQueryBuilderCallback? builder,
  }) async {
    dynamic query = _base.delete();
    query = _applyBuilder(query, builder);
    await query;
  }

  Stream<List<Map<String, dynamic>>> stream({
    required List<String> primaryKey,
    SupabaseQueryBuilderCallback? builder,
  }) {
    dynamic query = _base.stream(primaryKey: primaryKey);
    query = _applyBuilder(query, builder);
    final stream = query as Stream<List<dynamic>>;
    return stream.map((event) => event.cast<Map<String, dynamic>>());
  }

  dynamic _applyBuilder(dynamic query, SupabaseQueryBuilderCallback? builder) {
    if (builder == null) {
      return query;
    }
    return builder(query);
  }
}

typedef SupabaseTableAdapterFactory = SupabaseTableAdapter Function(
  SupabaseService service,
  String tableName,
);

SupabaseTableAdapter defaultSupabaseTableFactory(
  SupabaseService service,
  String table,
) {
  final builder = service.client.from(table);
  return SupabaseTableAdapter(builder);
}
