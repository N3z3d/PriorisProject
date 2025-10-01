/// Represents a single entry in the cache with metadata
class CacheEntry {
  /// The actual cached value
  final dynamic value;

  /// When the entry was created
  final DateTime createdAt;

  /// When the entry expires (null for no expiration)
  final DateTime? expiresAt;

  /// Size of the entry in bytes
  final int size;

  /// Number of times this entry has been accessed
  int accessCount;

  /// Last time this entry was accessed
  DateTime lastAccessed;

  /// Tags associated with this entry for bulk invalidation
  final List<String> tags;

  /// Whether this entry was loaded from persistent storage
  final bool fromPersistentCache;

  /// Whether this entry is compressed
  final bool isCompressed;

  /// Whether this entry is encrypted
  final bool isEncrypted;

  /// Priority score for eviction (higher = keep longer)
  double priority;

  /// Version of the cached value (for cache coherence)
  final String? version;

  /// Metadata associated with the entry
  final Map<String, dynamic> metadata;

  CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    required this.size,
    this.accessCount = 0,
    DateTime? lastAccessed,
    this.tags = const <String>[],
    this.fromPersistentCache = false,
    this.isCompressed = false,
    this.isEncrypted = false,
    this.priority = 0.5,
    this.version,
    this.metadata = const <String, dynamic>{},
  }) : lastAccessed = lastAccessed ?? createdAt;

  /// Whether this entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Age of the entry
  Duration get age => DateTime.now().difference(createdAt);

  /// Time since last access
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessed);

  /// Time until expiration (null if no expiration)
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether this entry should be considered "hot" (frequently accessed)
  bool get isHot {
    const hotThreshold = 10;
    const recentThreshold = Duration(minutes: 30);

    return accessCount >= hotThreshold ||
           timeSinceLastAccess < recentThreshold;
  }

  /// Access frequency (accesses per hour since creation)
  double get accessFrequency {
    final hoursAlive = age.inMinutes / 60.0;
    return hoursAlive > 0 ? accessCount / hoursAlive : accessCount.toDouble();
  }

  /// Records an access to this entry
  void recordAccess() {
    accessCount++;
    lastAccessed = DateTime.now();
  }

  /// Updates the priority score for eviction algorithms
  void updatePriority(double newPriority) {
    priority = newPriority.clamp(0.0, 1.0);
  }

  /// Creates a copy of this entry with updated metadata
  CacheEntry copyWith({
    dynamic value,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? size,
    int? accessCount,
    DateTime? lastAccessed,
    List<String>? tags,
    bool? fromPersistentCache,
    bool? isCompressed,
    bool? isEncrypted,
    double? priority,
    String? version,
    Map<String, dynamic>? metadata,
  }) {
    return CacheEntry(
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      size: size ?? this.size,
      accessCount: accessCount ?? this.accessCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      tags: tags ?? this.tags,
      fromPersistentCache: fromPersistentCache ?? this.fromPersistentCache,
      isCompressed: isCompressed ?? this.isCompressed,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      priority: priority ?? this.priority,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Serializes the entry to a map for persistence
  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'size': size,
      'accessCount': accessCount,
      'lastAccessed': lastAccessed.toIso8601String(),
      'tags': tags,
      'fromPersistentCache': fromPersistentCache,
      'isCompressed': isCompressed,
      'isEncrypted': isEncrypted,
      'priority': priority,
      'version': version,
      'metadata': metadata,
    };
  }

  /// Creates a CacheEntry from a serialized map
  static CacheEntry fromMap(Map<String, dynamic> map) {
    return CacheEntry(
      value: map['value'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      size: map['size'] ?? 0,
      accessCount: map['accessCount'] ?? 0,
      lastAccessed: map['lastAccessed'] != null
          ? DateTime.parse(map['lastAccessed'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      fromPersistentCache: map['fromPersistentCache'] ?? false,
      isCompressed: map['isCompressed'] ?? false,
      isEncrypted: map['isEncrypted'] ?? false,
      priority: (map['priority'] ?? 0.5).toDouble(),
      version: map['version'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Returns a summary of the entry for debugging
  Map<String, dynamic> getSummary() {
    return {
      'age_minutes': age.inMinutes,
      'access_count': accessCount,
      'time_since_last_access_minutes': timeSinceLastAccess.inMinutes,
      'size_bytes': size,
      'is_expired': isExpired,
      'is_hot': isHot,
      'access_frequency': accessFrequency.toStringAsFixed(2),
      'priority': priority.toStringAsFixed(2),
      'tags_count': tags.length,
      'from_persistent': fromPersistentCache,
      'compressed': isCompressed,
      'encrypted': isEncrypted,
    };
  }

  @override
  String toString() {
    return 'CacheEntry(age: ${age.inMinutes}min, accesses: $accessCount, '
           'size: ${size}b, expired: $isExpired, hot: $isHot)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CacheEntry &&
        other.value == value &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(value, createdAt, expiresAt, version);
  }
}

/// Cache entry builder for fluent construction
class CacheEntryBuilder {
  dynamic _value;
  DateTime? _createdAt;
  DateTime? _expiresAt;
  int _size = 0;
  int _accessCount = 0;
  DateTime? _lastAccessed;
  List<String> _tags = <String>[];
  bool _fromPersistentCache = false;
  bool _isCompressed = false;
  bool _isEncrypted = false;
  double _priority = 0.5;
  String? _version;
  Map<String, dynamic> _metadata = <String, dynamic>{};

  CacheEntryBuilder(this._value);

  CacheEntryBuilder withCreationTime(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  CacheEntryBuilder withExpiration(DateTime expiresAt) {
    _expiresAt = expiresAt;
    return this;
  }

  CacheEntryBuilder withTTL(Duration ttl) {
    _expiresAt = DateTime.now().add(ttl);
    return this;
  }

  CacheEntryBuilder withSize(int size) {
    _size = size;
    return this;
  }

  CacheEntryBuilder withAccessCount(int count) {
    _accessCount = count;
    return this;
  }

  CacheEntryBuilder withLastAccessed(DateTime lastAccessed) {
    _lastAccessed = lastAccessed;
    return this;
  }

  CacheEntryBuilder withTags(List<String> tags) {
    _tags = tags;
    return this;
  }

  CacheEntryBuilder withTag(String tag) {
    _tags.add(tag);
    return this;
  }

  CacheEntryBuilder fromPersistentCache() {
    _fromPersistentCache = true;
    return this;
  }

  CacheEntryBuilder compressed() {
    _isCompressed = true;
    return this;
  }

  CacheEntryBuilder encrypted() {
    _isEncrypted = true;
    return this;
  }

  CacheEntryBuilder withPriority(double priority) {
    _priority = priority;
    return this;
  }

  CacheEntryBuilder withVersion(String version) {
    _version = version;
    return this;
  }

  CacheEntryBuilder withMetadata(Map<String, dynamic> metadata) {
    _metadata = Map.from(metadata);
    return this;
  }

  CacheEntryBuilder addMetadata(String key, dynamic value) {
    _metadata[key] = value;
    return this;
  }

  CacheEntry build() {
    return CacheEntry(
      value: _value,
      createdAt: _createdAt ?? DateTime.now(),
      expiresAt: _expiresAt,
      size: _size,
      accessCount: _accessCount,
      lastAccessed: _lastAccessed,
      tags: _tags,
      fromPersistentCache: _fromPersistentCache,
      isCompressed: _isCompressed,
      isEncrypted: _isEncrypted,
      priority: _priority,
      version: _version,
      metadata: _metadata,
    );
  }
}

/// Utility functions for cache entries
class CacheEntryUtils {
  /// Calculates the total size of multiple cache entries
  static int calculateTotalSize(Iterable<CacheEntry> entries) {
    return entries.map((entry) => entry.size).fold(0, (sum, size) => sum + size);
  }

  /// Finds entries that match all provided tags
  static List<CacheEntry> filterByTags(
    Iterable<CacheEntry> entries,
    List<String> tags,
  ) {
    return entries
        .where((entry) => tags.every((tag) => entry.tags.contains(tag)))
        .toList();
  }

  /// Finds entries that match any of the provided tags
  static List<CacheEntry> filterByAnyTag(
    Iterable<CacheEntry> entries,
    List<String> tags,
  ) {
    return entries
        .where((entry) => entry.tags.any((tag) => tags.contains(tag)))
        .toList();
  }

  /// Sorts entries by access frequency (descending)
  static List<CacheEntry> sortByAccessFrequency(Iterable<CacheEntry> entries) {
    final list = entries.toList();
    list.sort((a, b) => b.accessFrequency.compareTo(a.accessFrequency));
    return list;
  }

  /// Sorts entries by age (ascending = oldest first)
  static List<CacheEntry> sortByAge(Iterable<CacheEntry> entries) {
    final list = entries.toList();
    list.sort((a, b) => a.age.compareTo(b.age));
    return list;
  }

  /// Sorts entries by size (descending = largest first)
  static List<CacheEntry> sortBySize(Iterable<CacheEntry> entries) {
    final list = entries.toList();
    list.sort((a, b) => b.size.compareTo(a.size));
    return list;
  }

  /// Finds expired entries
  static List<CacheEntry> findExpiredEntries(Iterable<CacheEntry> entries) {
    return entries.where((entry) => entry.isExpired).toList();
  }

  /// Finds hot entries (frequently accessed)
  static List<CacheEntry> findHotEntries(Iterable<CacheEntry> entries) {
    return entries.where((entry) => entry.isHot).toList();
  }

  /// Calculates memory efficiency (useful data vs total size)
  static double calculateMemoryEfficiency(Iterable<CacheEntry> entries) {
    if (entries.isEmpty) return 1.0;

    final totalSize = calculateTotalSize(entries);
    final activeEntries = entries.where((entry) => !entry.isExpired);
    final activeSize = calculateTotalSize(activeEntries);

    return totalSize > 0 ? activeSize / totalSize : 0.0;
  }
}