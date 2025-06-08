import 'package:equatable/equatable.dart';
import 'package:eventorize_app/data/models/event.dart';

class Favorite extends Equatable {
  final String id;
  final String eventId;
  final Event? event;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Favorite({
    required this.id,
    required this.eventId,
    this.event,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'] as String,
      eventId: (json['event'] != null ? json['event']['_id'] : json['event_id']) as String,
      event: json['event'] != null ? Event.fromJson(json['event'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      updatedBy: json['updated_by'] as String?,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      deletedBy: json['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event_id': eventId,
      'event': event?.toJson(),
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
        eventId,
        event,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}