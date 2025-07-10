import 'package:equatable/equatable.dart';

class Organizer extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String email;
  final String? phone;
  final String? description;
  final String? country;
  final String? city;
  final String? district;
  final String? ward;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? instagram;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Organizer({
    required this.id,
    required this.name,
    this.logo,
    required this.email,
    this.phone,
    this.description,
    this.country,
    this.city,
    this.district,
    this.ward,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.instagram,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String dateStr) {
      return DateTime.parse(dateStr).toLocal();
    }

    return Organizer(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      linkedin: json['linkedin'] as String?,
      instagram: json['instagram'] as String?,
      createdAt: parseDateTime(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      updatedAt: json['updated_at'] != null ? parseDateTime(json['updated_at'] as String) : null,
      updatedBy: json['updated_by'] as String?,
      deletedAt: json['deleted_at'] != null ? parseDateTime(json['deleted_at'] as String) : null,
      deletedBy: json['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDateTime(DateTime? date) {
      if (date == null) return null;
      final offset = const Duration(hours: 7);
      final adjusted = date.toUtc().add(offset);
      return adjusted.toIso8601String();
    }

    return {
      '_id': id,
      'name': name,
      'logo': logo,
      'email': email,
      'phone': phone,
      'description': description,
      'country': country,
      'city': city,
      'district': district,
      'ward': ward,
      'facebook': facebook,
      'twitter': twitter,
      'linkedin': linkedin,
      'instagram': instagram,
      'created_at': formatDateTime(createdAt),
      'created_by': createdBy,
      'updated_at': formatDateTime(updatedAt),
      'updated_by': updatedBy,
      'deleted_at': formatDateTime(deletedAt),
      'deleted_by': deletedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logo,
        email,
        phone,
        description,
        country,
        city,
        district,
        ward,
        facebook,
        twitter,
        linkedin,
        instagram,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}