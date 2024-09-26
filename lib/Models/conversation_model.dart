import 'package:flutter/material.dart';

class ConversationModel {
  final String senderId;
  final String receiverId;
  final String lastMessage;
  final String lastMessageTime;
  final String petId;

  ConversationModel(
      {required this.senderId,
      required this.receiverId,
      required this.lastMessage,
      required this.petId,
      required this.lastMessageTime});
}
