import 'package:flutter/material.dart';
import 'package:flutter_chat/provider/change.dart';
import 'package:provider/provider.dart';

class ChatTile extends StatefulWidget {
  ChatTile(
      {super.key,
      required this.messageId,
      required this.message,
      required this.senderName,
      required this.imageUrl,
      required this.sentByMe});
  String messageId;
  String message;
  String senderName;
  bool sentByMe;
  String imageUrl;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  String selectedMessage = '';

  bool longPressed = false;
  bool singleTap = true;
  @override
  Widget build(BuildContext context) {
    var change = Provider.of<Change>(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (longPressed == true) {
            longPressed = false;
            change.removeMessageFromList(widget.messageId);
          } else {
            singleTap = !singleTap;
            if (singleTap == true) {
              change.addMessageToList(widget.messageId);
            } else {
              change.removeMessageFromList(widget.messageId);
            }
          }
        });
      },
      onLongPress: () {
        change.doTrue();
        change.changeIsItemSelected();
        setState(() {
          change.addMessageToList(widget.messageId);
          longPressed = true;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: change.getChange
                ? change.getMessageIds.contains(widget.messageId)
                    ? Colors.grey.shade300
                    : null
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: widget.sentByMe ? 0 : 24,
            right: widget.sentByMe ? 24 : 0),
        alignment:
            widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: widget.sentByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding:
              const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: widget.sentByMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
              color: widget.sentByMe
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.senderName.toUpperCase(),
                textAlign: TextAlign.start,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(widget.message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              if (widget.imageUrl != '')
                Image.network(
                  widget.imageUrl,
                  width: 100,
                  height: 100,
                )
            ],
          ),
        ),
      ),
    );
  }
}
