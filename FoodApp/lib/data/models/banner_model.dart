class BannerModel {
  String id;
  String title;
  String subTitle;
  String image;
  String link;
  BannerModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.image,
    required this.link,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'subTitle': subTitle,
      'image': image,
      'link': link,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      title: map['title'] ?? '',
      subTitle: map['subTitle'] ?? '',
      image: map['image'] ?? "",
      link: map['link'] ?? "",
    );
  }
}
