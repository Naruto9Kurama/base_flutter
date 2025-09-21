
import 'package:json_annotation/json_annotation.dart';

part 'ali_token_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AliTokenResponse {
   final String token_type;
   final String access_token;
   final String refresh_token;
   final double expires_in;


   AliTokenResponse({
    required this.token_type,
    required this.access_token,
    required this.refresh_token,
    required this.expires_in,
  });
  factory AliTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AliTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AliTokenResponseToJson(this);
}