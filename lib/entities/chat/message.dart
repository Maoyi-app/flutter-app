

import 'package:json_annotation/json_annotation.dart';

part 'message.dart.g';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Message {
  num id;
  num createdDate;
  num senderId;
  String content;

  Message({this.id, this.createdDate, this.senderId, this.content});


  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}