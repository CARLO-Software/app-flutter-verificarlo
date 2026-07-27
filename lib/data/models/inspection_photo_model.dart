class InspectionPhoto {
  final int? id;
  final String url;
  final String? itemId;
  final bool isUploaded;

  const InspectionPhoto({
    this.id,
    required this.url,
    this.itemId,
    this.isUploaded = true,
  });

  factory InspectionPhoto.fromJson(Map<String, dynamic> json) => InspectionPhoto(
        id: json['id'] as int?,
        url: json['url'] as String,
        itemId: json['itemId'] as String?,
      );
}
