import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Province extends Equatable {
  final String? name;
  final int? code;
  final String? divisionType;
  final String? codename;

  const Province({
    this.name,
    this.code,
    this.divisionType,
    this.codename,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'] as String?,
      code: json['code'] as int?,
      divisionType: json['division_type'] as String?,
      codename: json['codename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'division_type': divisionType,
      'codename': codename,
    };
  }

  @override
  List<Object?> get props => [name, code, divisionType, codename];
}

@immutable
class District extends Equatable {
  final String? name;
  final int? code;
  final String? divisionType;
  final String? codename;
  final int? provinceCode;

  const District({
    this.name,
    this.code,
    this.divisionType,
    this.codename,
    this.provinceCode,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['name'] as String?,
      code: json['code'] as int?,
      divisionType: json['division_type'] as String?,
      codename: json['codename'] as String?,
      provinceCode: json['province_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'division_type': divisionType,
      'codename': codename,
      'province_code': provinceCode,
    };
  }

  @override
  List<Object?> get props => [name, code, divisionType, codename, provinceCode];
}
@immutable
class Ward extends Equatable {
  final String? name;
  final int? code;
  final String? divisionType;
  final String? codename;
  final int? districtCode;

  const Ward({
    this.name,
    this.code,
    this.divisionType,
    this.codename,
    this.districtCode,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      name: json['name'] as String?,
      code: json['code'] as int?,
      divisionType: json['division_type'] as String?,
      codename: json['codename'] as String?,
      districtCode: json['district_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'division_type': divisionType,
      'codename': codename,
      'district_code': districtCode,
    };
  }

  @override
  List<Object?> get props => [name, code, divisionType, codename, districtCode];
}