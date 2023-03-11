import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

// ignore: must_be_immutable
class VideoConference extends StatelessWidget {
  VideoConference({super.key});
  static const routName = 'videoconference';
  late String userId;
  late String userName;
  late String groupName;
  late String groupId;

  final int appId = 393989659;
  final String appSign =
      'f62b4da40f9d6b629958dc3c108f1bc544e0ea9c959c5b9982292ec090cecc6b';

  @override
  Widget build(BuildContext context) {
    var data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    groupId = data['groupId'];
    groupName = data['groupName'];
    userName = data['userName'];
    userId = data['userId'];

    return SafeArea(
        child: ZegoUIKitPrebuiltVideoConference(
            appID: appId,
            appSign: appSign,
            conferenceID: groupId,
            userID: userId,
            userName: userName,
            // modify your custom configuration here
            config: ZegoUIKitPrebuiltVideoConferenceConfig(
                turnOnMicrophoneWhenJoining: false,
                turnOnCameraWhenJoining: true,
                useSpeakerWhenJoining: false)));
  }
}
