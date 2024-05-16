import 'dart:convert';

import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyDialog {
  void showAddAccountDialog(
  {required BuildContext context,
  required,
  required ProfileModel profileModel}) {
var otpTextStyles = [
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
Theme.of(context).textTheme.headline3?.copyWith(color: Colors.blue),
];

showDialog(
context: context,
builder: (BuildContext context) {
return StatefulBuilder(
builder:
(BuildContext context, void Function(void Function()) setState) {
return AlertDialog(
title: Text(LocaleKeys.addAccount.tr,
style: TextStyle(
color: Helper.getTextColor(context),
fontSize: 25,
fontWeight: FontWeight.bold)),
content: SingleChildScrollView(
child: ListBody(
children: <Widget>[
Text(LocaleKeys.sixDigitCode.tr,
style: TextStyle(
color: Helper.getTextColor(context),
fontSize: 16,
fontWeight: FontWeight.w300)),
OtpTextField(
numberOfFields: 6,
fieldWidth: 35,
focusedBorderColor: Colors.blue,
styles: otpTextStyles,
borderWidth: 4,
keyboardType: TextInputType.text,
onCodeChanged: (String code) {},
onSubmit: (String verificationCode) {
if (profileModel.user_code == verificationCode) {
Helper.showToast(LocaleKeys.addOtherRequestCode.tr);
} else {
validateCode(context, verificationCode, profileModel);
}
},
),
],
),
),
actions: <Widget>[
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
TextButton(
onPressed: () {
Navigator.of(context).pop();
},
child: Text(LocaleKeys.close.tr),
),
],
),
],
);
},
);
},
);
}

Future validateCode(BuildContext context, String verificationCode,
    ProfileModel profileModel) async {
  bool profileExist = false;
  final reference =
  FirebaseDatabase.instance.reference().child(profile_table);

  reference.once().then((event) {
    DataSnapshot dataSnapshot = event.snapshot;
    Map<dynamic, dynamic> values =
    dataSnapshot.value as Map<dynamic, dynamic>;
    values.forEach((key, values) {
      if (values['user_code'] == verificationCode) {
        profileExist = true;
        createRequest(context, profileModel, values['email'],values['full_name']);
        Navigator.pop(context);
      }
    });
    if (!profileExist) {
      Helper.showToast(LocaleKeys.userNotExist.tr);
    }
  });
}

Future<void> createRequest(BuildContext context, ProfileModel profileModel,
    String receiverEmail,String receiverName) async {
  final reference =
  FirebaseDatabase.instance.reference().child(request_table);

  bool requestExist=false;
  reference.once().then((event) {
    DataSnapshot dataSnapshot = event.snapshot;
    if (dataSnapshot.exists) {
      Map<dynamic, dynamic> values =
      dataSnapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, values) {
        if (values['receiver_email'] == receiverEmail &&
            values['status'] == AppConstanst.pendingRequest) {
          requestExist = true;
          Helper.showToast(LocaleKeys.alreadyExist.tr);
        }else if (values['receiver_email'] == receiverEmail &&
            values['status'] == AppConstanst.acceptedRequest) {
          requestExist = true;
          Helper.showToast(LocaleKeys.alreadyHaveAccess.tr);
        }
        if(!requestExist){
          var newPostRef = reference.push();
          RequestModel data = RequestModel(
            key: newPostRef.key,
            requester_email: profileModel.email,
            requester_name: profileModel.full_name,
            receiver_email: receiverEmail,
            receiver_name: receiverName,
            status: 1,
            created_at: DateTime.now().toString(),
          );

          newPostRef.set(data.toMap());
          sendRequestNotification(data, profileModel);
          Helper.showToast(LocaleKeys.requestSentSuccessFully.tr);
        }
      });
    }else{
      var newPostRef = reference.push();
      RequestModel data = RequestModel(
        key: newPostRef.key,
        requester_email: profileModel.email,
        requester_name: profileModel.full_name,
        receiver_email: receiverEmail,
        receiver_name: receiverName,
        status: 1,
        created_at: DateTime.now().toString(),
      );

      newPostRef.set(data.toMap());
      sendRequestNotification(data, profileModel);
      Helper.showToast(LocaleKeys.requestSentSuccessFully.tr);
    }

  });
}

void sendRequestNotification(
    RequestModel requesterModel, ProfileModel profileModel) async {
  final reference = FirebaseDatabase.instance
      .reference()
      .child(profile_table)
      .orderByChild('email')
      .equalTo(requesterModel.receiver_email);

  reference.onValue.listen((event) {
    DataSnapshot dataSnapshot = event.snapshot;
    if (event.snapshot.exists) {
      Map<dynamic, dynamic> values =
      dataSnapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) async {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':'key=AAAANkNYKio:APA91bHGQs2MllIVYtH83Lunknc7v8dXwEPlaqNKpM5u6oHIx3kNYU2VFNuYpEyVzg3hqWjoR-WzWiWMmDN8RrO1QwzEqIrGST726TgPxkp87lqbEI515NzGt7HYdCbrljuH0uldBCW8'
          },
          body: jsonEncode({
            'to': value['fcm_token'],
            'priority': 'high',
            'notification': {
              'title': 'Hello ${requesterModel.receiver_name},',
              'body':
              'You have a new request from ${requesterModel.requester_name}',
            },
          }),
        );
      });
    }
  });
}
}
