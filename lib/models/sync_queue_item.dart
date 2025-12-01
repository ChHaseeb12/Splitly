/// Model for sync queue items
/// Tracks operations that need to be synced to Firestore
class SyncQueueItem {
  final String id;
  final String operation; // CREATE, UPDATE, DELETE
  final String collection; // expenses, groups, friends, etc.
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final String? error;

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'error': error,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'],
      operation: json['operation'],
      collection: json['collection'],
      documentId: json['documentId'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      error: json['error'],
    );
  }

  SyncQueueItem copyWith({
    String? id,
    String? operation,
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}
