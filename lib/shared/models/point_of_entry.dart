class PointOfEntry {
  final String code;
  final String name;
  final String? orgUnitUid; // matches the QR payload's portOfEntry field
  final String? borderType; // live group name: Air / Land / Lake / Sea

  const PointOfEntry({
    required this.code,
    required this.name,
    this.orgUnitUid,
    this.borderType,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        if (orgUnitUid != null) 'orgUnitUid': orgUnitUid,
        if (borderType != null) 'borderType': borderType,
      };

  factory PointOfEntry.fromJson(Map<String, dynamic> json) {
    return PointOfEntry(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      orgUnitUid: json['orgUnitUid']?.toString(),
      borderType: json['borderType']?.toString(),
    );
  }
}