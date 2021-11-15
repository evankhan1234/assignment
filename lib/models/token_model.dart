// To parse this JSON data, do
//
//     final tokenModel = tokenModelFromJson(jsonString);

import 'dart:convert';

TokenModel tokenModelFromJson(String str) => TokenModel.fromJson(json.decode(str));

String tokenModelToJson(TokenModel data) => json.encode(data.toJson());

class TokenModel {
  TokenModel({
    required this.tokens,
  });

  List<String> tokens;

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    tokens: List<String>.from(json["tokens"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "tokens": List<String>.from(tokens.map((x) => x)),
  };
}
