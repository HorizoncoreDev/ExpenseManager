import 'dart:convert';

import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'add_account_screen.dart';
import 'bloc/family_account_bloc.dart';
import 'bloc/family_account_state.dart';

class FamilyAccountScreen extends StatefulWidget {
  const FamilyAccountScreen({super.key});

  @override
  State<FamilyAccountScreen> createState() => _FamilyAccountScreenState();
}

class _FamilyAccountScreenState extends State<FamilyAccountScreen> {
  FamilyAccountBloc familyAccountBloc = FamilyAccountBloc();
  final databaseHelper = DatabaseHelper.instance;
  String userEmail = '';
  bool isLoading = true;
  ProfileModel? profileData;
  List<RequestModel?> requestList = [];
  List<RequestModel?> accessRequestList = [];

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;

        getRequestList();
      });
    } catch (error) {
      Helper.hideLoading(context);
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getRequestList() async {

    final reference = FirebaseDatabase.instance
        .reference()
        .child(request_table)
        .orderByChild('receiver_email')
        .equalTo(profileData!.email);

    reference.onValue.listen((event) {
      requestList = [];
      requestList.clear();
      isLoading = false;
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) async {
          if (value['status'] != AppConstanst.rejectedRequest) {
            RequestModel requestModel = RequestModel(
                key: key,
                requester_email: value['requester_email'],
                requester_name: value['requester_name'],
                receiver_email: value['receiver_email'],
                receiver_name: value['receiver_name'],
                status: value['status'],
                created_at: value['created_at']);
            requestList.add(requestModel);
          }
        });
      }
      setState(() {});
    });

    final accessReference = FirebaseDatabase.instance
        .reference()
        .child(request_table)
        .orderByChild('requester_email')
        .equalTo(profileData!.email);

    accessReference.onValue.listen((event) {
      accessRequestList = [];
      accessRequestList.clear();
      isLoading = false;
      DataSnapshot dataSnapshot = event.snapshot;
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            dataSnapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          if (value['status'] == AppConstanst.acceptedRequest) {
            RequestModel requestModel = RequestModel(
                key: key,
                requester_email: value['requester_email'],
                requester_name: value['requester_name'],
                receiver_email: value['receiver_email'],
                receiver_name: value['receiver_name'],
                status: value['status'],
                created_at: value['created_at']);
            accessRequestList.add(requestModel);
          }
        });
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    AppConstanst.notificationClicked = false;
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userEmail)
        .then((value) {
      if (value != null) {
        userEmail = value;
        getProfileData();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    familyAccountBloc.context = context;

    return BlocConsumer<FamilyAccountBloc, FamilyAccountState>(
      bloc: familyAccountBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is FamilyAccountInitial) {
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 15,
                automaticallyImplyLeading: false,
                backgroundColor: Helper.getBackgroundColor(context),
                title: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Helper.getTextColor(context),
                        )),
                    Text("My Family",
                        style: TextStyle(
                          fontSize: 22,
                          color: Helper.getTextColor(context),
                        )),
                  ],
                ),
              ),
              bottomNavigationBar: InkWell(
                onTap: () {
                  MyDialog().showAddAccountDialog(
                      context: context, profileModel: profileData!);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const Text(
                    "Add Account",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              body: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      width: double.infinity,
                      color: Helper.getBackgroundColor(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.heightBox,
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  requestList.isNotEmpty
                                      ? "Currently ${1 + requestList.length} members"
                                      : "Currently 1 member",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context)),
                                ),
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "CODE: ",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                      children: [
                                    TextSpan(
                                      text: profileData != null
                                          ? profileData!.user_code
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ])),
                            ],
                          ),
                          10.heightBox,
                          Container(
                            decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius: accessRequestList.isEmpty
                                  ? const BorderRadius.all(Radius.circular(10))
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 7),
                                  decoration: BoxDecoration(
                                      color: Helper.getBackgroundColor(context),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                    profileData != null
                                        ? Helper.getShortName(
                                            profileData!.first_name!,
                                            profileData!.last_name!)
                                        : 'AB',
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                20.widthBox,
                                Text(
                                  profileData != null
                                      ? profileData!.full_name!
                                      : '',
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          if (accessRequestList.isNotEmpty)
                            const Divider(
                              thickness: 1,
                              height: 1,
                              color: Colors.black12,
                            ),
                          if (accessRequestList.isNotEmpty)
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Helper.getCardColor(context),
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: accessRequestList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 7),
                                            decoration: BoxDecoration(
                                                color:
                                                    Helper.getBackgroundColor(
                                                        context),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                            child: Text(
                                              Helper.getShortName(
                                                  accessRequestList[index]!
                                                      .receiver_name!
                                                      .split(' ')[0],
                                                  accessRequestList[index]!
                                                      .receiver_name!
                                                      .split(' ')[1]),
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          20.widthBox,
                                          Expanded(
                                            child: Text(
                                              accessRequestList[index]!
                                                  .receiver_name!,
                                              style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Colors.black12,
                                    );
                                  },
                                ),
                              ),
                            ),
                          15.heightBox,
                          if (requestList.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  'REQUESTS(${requestList.length})',
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          if (requestList.isNotEmpty) 5.heightBox,
                          if (requestList.isNotEmpty)
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Helper.getCardColor(context),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: requestList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 7),
                                            decoration: BoxDecoration(
                                                color:
                                                    Helper.getBackgroundColor(
                                                        context),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10))),
                                            child: Text(
                                              Helper.getShortName(
                                                  requestList[index]!
                                                      .requester_name!
                                                      .split(' ')[0],
                                                  requestList[index]!
                                                      .requester_name!
                                                      .split(' ')[1]),
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          20.widthBox,
                                          Expanded(
                                            child: Text(
                                              requestList[index]!
                                                  .requester_name!,
                                              style: TextStyle(
                                                  color: Helper.getTextColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (requestList[index]!.status ==
                                              AppConstanst.pendingRequest)
                                            InkWell(
                                              onTap: () {
                                                _acceptRequest(
                                                    requestList[index]!);
                                              },
                                              child: SvgPicture.asset(
                                                'asset/images/ic_accept.svg',
                                                color: Colors.green,
                                                height: 24,
                                                width: 24,
                                              ),
                                            ),
                                          if (requestList[index]!.status ==
                                              AppConstanst.pendingRequest)
                                            8.widthBox,
                                          if (requestList[index]!.status ==
                                              AppConstanst.pendingRequest)
                                            InkWell(
                                                onTap: () {
                                                  _rejectRequest(
                                                      requestList[index]!);
                                                },
                                                child: SvgPicture.asset(
                                                  'asset/images/ic_reject.svg',
                                                  height: 24,
                                                  width: 24,
                                                )),
                                          if (requestList[index]!.status ==
                                              AppConstanst.acceptedRequest)
                                            InkWell(
                                                onTap: () {
                                                  _removeRequest(
                                                      requestList[index]!);
                                                },
                                                child: const Icon(
                                                  Icons.remove_circle_rounded,
                                                  color: Colors.red,
                                                  size: 30,
                                                ))
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Colors.black12,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ));
        }
        return Container();
      },
    );
  }

  _acceptRequest(RequestModel requestModel) {
    requestModel.status = AppConstanst.acceptedRequest;

    final Map<String, Map> updates = {};
    updates['/$request_table/${requestModel.key}'] = requestModel.toMap();
    FirebaseDatabase.instance.ref().update(updates).then((value) {
      sendNotification(requestModel, profileData!);
      getRequestList();
    });
  }

  void sendNotification(
      RequestModel requestModel, ProfileModel profileModel) async {
    final reference = FirebaseDatabase.instance
        .reference()
        .child(profile_table)
        .orderByChild('email')
        .equalTo(requestModel.requester_email);

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
                'title': 'Hello ${requestModel.requester_name},',
                'body': requestModel.status == AppConstanst.acceptedRequest
                    ? '${requestModel.receiver_name} has accepted your request'
                    : requestModel.status == AppConstanst.rejectedRequest
                        ? '${requestModel.receiver_name} has rejected your request'
                        : '${requestModel.receiver_name} has removed your access',
              },
            }),
          );
        });
      }
    });
  }

  _rejectRequest(RequestModel requestModel) {
    requestModel.status = AppConstanst.rejectedRequest;

    final Map<String, Map> updates = {};
    updates['/$request_table/${requestModel.key}'] = requestModel.toMap();
    FirebaseDatabase.instance.ref().update(updates).then((value) {
      sendNotification(requestModel, profileData!);
      getRequestList();
    });
  }

  _removeRequest(RequestModel requestModel) {
    requestModel.status = AppConstanst.removedRequest;
    final reference =
        FirebaseDatabase.instance.reference().child(request_table);
    reference.child(requestModel.key!).remove().then((value) {
      sendNotification(requestModel, profileData!);
      getRequestList();
    });
  }
}
