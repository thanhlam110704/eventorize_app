import 'package:equatable/equatable.dart';
import 'package:eventorize_app/data/models/event.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final List<String> listEventId;
  final List<Event>? events;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Favorite({
    required this.id,
    required this.userId,
    required this.listEventId,
    this.events,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    final events = (json['events'] as List<dynamic>?)
        ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
    return Favorite(
      id: json['_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      listEventId: json['list_event_id'] != null
          ? (json['list_event_id'] as List<dynamic>).cast<String>()
          : events?.map((e) => e.id).toList() ?? [], 
      events: events,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      updatedBy: json['updated_by'] as String?,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deletedBy: json['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'list_event_id': listEventId,
      'events': events?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        listEventId,
        events,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}