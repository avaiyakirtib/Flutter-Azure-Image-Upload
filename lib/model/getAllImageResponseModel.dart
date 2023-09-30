// To parse this JSON data, do
//
//     final getAllImageResponseModel = getAllImageResponseModelFromJson(jsonString);

import 'dart:convert';

GetAllImageResponseModel getAllImageResponseModelFromJson(String str) =>
    GetAllImageResponseModel.fromJson(json.decode(str));

String getAllImageResponseModelToJson(GetAllImageResponseModel data) =>
    json.encode(data.toJson());

class GetAllImageResponseModel {
  String? message;
  List<Images>? images;

  GetAllImageResponseModel({
    this.message,
    this.images,
  });

  factory GetAllImageResponseModel.fromJson(Map<String, dynamic> json) =>
      GetAllImageResponseModel(
        message: json["message"],
        images: json["images"] == null
            ? []
            : List<Images>.from(json["images"]!.map((x) => Images.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
      };
}

class Images {
  String? name;
  String? url;

  Images({
    this.name,
    this.url,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };
}
