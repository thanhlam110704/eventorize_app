import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id; 
  final String fullname;
  final String email;
  final String? position;
  final String? phone;
  final String? avatar;
  final String? company;
  final String? country;
  final String? city;
  final String? district;
  final String? ward;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? instagram;
  final String? password; 
  final String? googleId;
  final String? githubId;
  final bool isVerified;
  final String? resetPasswordOtp;
  final DateTime? resetPasswordOtpExpire;
  final int? resetPasswordAttempts;
  final String? verifyEmailOtp;
  final DateTime? verifyEmailOtpExpire;
  final int? verifyEmailOtpAttempts;
  final String type;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy; 

  const User({
    required this.id,
    required this.fullname,
    required this.email,
    this.position,
    this.phone,
    this.avatar,
    this.company,
    this.country,
    this.city,
    this.district,
    this.ward,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.instagram,
    this.password,
    this.googleId,
    this.githubId,
    this.isVerified = false,
    this.resetPasswordOtp,
    this.resetPasswordOtpExpire,
    this.resetPasswordAttempts,
    this.verifyEmailOtp,
    this.verifyEmailOtpExpire,
    this.verifyEmailOtpAttempts,
    required this.type,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String, // BE thường trả về ObjectIdStr dưới dạng '_id'
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      position: json['position'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      company: json['company'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      linkedin: json['linkedin'] as String?,
      instagram: json['instagram'] as String?,
      password: json['password'] as String?, // Nếu BE trả về dạng string đã mã hóa
      googleId: json['google_id'] as String?,
      githubId: json['github_id'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      resetPasswordOtp: json['reset_password_otp'] as String?,
      resetPasswordOtpExpire: json['reset_password_otp_expire'] != null
          ? DateTime.parse(json['reset_password_otp_expire'] as String)
          : null,
      resetPasswordAttempts: json['reset_password_attempts'] as int?,
      verifyEmailOtp: json['verify_email_otp'] as String?,
      verifyEmailOtpExpire: json['verify_email_otp_expire'] != null
          ? DateTime.parse(json['verify_email_otp_expire'] as String)
          : null,
      verifyEmailOtpAttempts: json['verify_email_otp_attempts'] as int?,
      type: json['type'] as String,
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
      'fullname': fullname,
      'email': email,
      'position': position,
      'phone': phone,
      'avatar': avatar,
      'company': company,
      'country': country,
      'city': city,
      'district': district,
      'ward': ward,
      'facebook': facebook,
      'twitter': twitter,
      'linkedin': linkedin,
      'instagram': instagram,
      'password': password,
      'google_id': googleId,
      'github_id': githubId,
      'is_verified': isVerified,
      'reset_password_otp': resetPasswordOtp,
      'reset_password_otp_expire': resetPasswordOtpExpire?.toIso8601String(),
      'reset_password_attempts': resetPasswordAttempts,
      'verify_email_otp': verifyEmailOtp,
      'verify_email_otp_expire': verifyEmailOtpExpire?.toIso8601String(),
      'verify_email_otp_attempts': verifyEmailOtpAttempts,
      'type': type,
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
        fullname,
        email,
        position,
        phone,
        avatar,
        company,
        country,
        city,
        district,
        ward,
        facebook,
        twitter,
        linkedin,
        instagram,
        password,
        googleId,
        githubId,
        isVerified,
        resetPasswordOtp,
        resetPasswordOtpExpire,
        resetPasswordAttempts,
        verifyEmailOtp,
        verifyEmailOtpExpire,
        verifyEmailOtpAttempts,
        type,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}