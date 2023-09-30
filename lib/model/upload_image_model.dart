// To parse this JSON data, do
//
//     final uploadImageModel = uploadImageModelFromJson(jsonString);

import 'dart:convert';

UploadImageModel uploadImageModelFromJson(String str) => UploadImageModel.fromJson(json.decode(str));

String uploadImageModelToJson(UploadImageModel data) => json.encode(data.toJson());

class UploadImageModel {
  String? message;
  String? imageUrl;

  UploadImageModel({
    this.message,
    this.imageUrl,
  });

  factory UploadImageModel.fromJson(Map<String, dynamic> json) => UploadImageModel(
    message: json["message"],
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "imageUrl": imageUrl,
  };
}
