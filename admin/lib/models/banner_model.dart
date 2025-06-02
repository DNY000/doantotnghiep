class BannerModel {
  String title;
  String subTitle;
  String image;
  String link;
  BannerModel({
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

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      title: map['title'] ?? '',
      subTitle: map['subTitle'] ?? '',
      image: map['image'] ?? "",
      link: map['link'] ?? "",
    );
  }
}
