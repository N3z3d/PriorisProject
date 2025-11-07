library advanced_cache;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:prioris/domain/services/cache/cache_policies.dart';
import 'package:prioris/domain/services/cache/cache_statistics.dart';
import 'package:prioris/domain/services/cache/core/cache_entry.dart';
import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';

typedef PrefetchStrategy = Future<List<String>> Function(String key);

part 'advanced_cache_core.dart';
part 'advanced_cache_policy.dart';
part 'advanced_cache_store.dart';
