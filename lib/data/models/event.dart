import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String organizerId;
  final String title;
  final String? thumbnail;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? link;
  final bool isOnline;
  final String? address;
  final String? district;
  final String? ward;
  final String? city;
  final String? country;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Event({
    required this.id,
    required this.organizerId,
    required this.title,
    this.thumbnail,
    this.description,
    required this.startDate,
    required this.endDate,
    this.link,
    required this.isOnline,
    this.address,
    this.district,
    this.ward,
    this.city,
    this.country,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as String,
      organizerId: json['organizer_id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String?,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      link: json['link'] as String?,
      isOnline: json['is_online'] as bool,
      address: json['address'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'organizer_id': organizerId,
      'title': title,
      'thumbnail': thumbnail,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'link': link,
      'is_online': isOnline,
      'address': address,
      'district': district,
      'ward': ward,
      'city': city,
      'country': country,
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
        organizerId,
        title,
        thumbnail,
        description,
        startDate,
        endDate,
        link,
        isOnline,
        address,
        district,
        ward,
        city,
        country,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}