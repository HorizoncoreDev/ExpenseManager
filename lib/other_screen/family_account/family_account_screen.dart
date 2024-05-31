import 'dart:convert';

import 'package:expense_manager/accounts/add_account_screen.dart';
import 'package:expense_manager/db_models/accounts_model.dart';
import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum AccessType { edit, viewOnly }

class FamilyAccountScreen extends StatefulWidget {
  const FamilyAccountScreen({super.key});

  @override
  State<FamilyAccountScreen> createState() => _FamilyAccountScreenState();
}

class _FamilyAccountScreenState extends State<FamilyAccountScreen> {
  final databaseHelper = DatabaseHelper.instance;
  String userEmail = '', userName = '', currentUserEmail = '', ownerKey = '';
  bool isLoading = true;
  ProfileModel? profileData;
  AccountsModel? accountsModel;
  List<RequestModel?> requestList = [];
  List<RequestModel?> accessRequestList = [];
  List<AccountsModel?> accountsList = [];

  @override
  Widget build(BuildContext context) {
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
              Text(LocaleKeys.myAccount.tr,
                  style: TextStyle(
                    fontSize: 22,
                    color: Helper.getTextColor(context),
                  )),
            ],
          ),
        ),
        bottomNavigationBar: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddAccountScreen(
                          account_name: "",
                          balance: "",
                          balance_date: "",
                          income: "",
                          budget: "",
                          description: "",
                          forEditAccount: false,
                          account_key: "",
                      owner_user_key: "",
                        ))).then((value) {
              if (value != null && value) {
                getAccountsList();
              }
            });
          },
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Text(
              LocaleKeys.addAccount.tr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
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
                            accountsList.isNotEmpty
                                ? "${LocaleKeys.currently.tr} ${accountsList.length} ${LocaleKeys.account.tr.toLowerCase()}"
                                : LocaleKeys.currentlyMember.tr,
                            style:
                                TextStyle(color: Helper.getTextColor(context)),
                          ),
                        ),
                        RichText(
                            text: TextSpan(
                                text: '${LocaleKeys.code.tr}: ',
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
                    /*InkWell(
                      onTap: () {
                        setState(() {
                          currentUserEmail = userEmail;
                        });
                        MySharedPreferences.instance.addStringToSF(
                            SharedPreferencesKeys.currentUserEmail, userEmail);
                        MySharedPreferences.instance.addStringToSF(
                            SharedPreferencesKeys.currentUserName, userName);

                        MySharedPreferences.instance.addStringToSF(
                            SharedPreferencesKeys.currentUserKey,
                            FirebaseAuth.instance.currentUser!.uid);
                      },
                      child: Container(
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
                            ),
                            if (currentUserEmail == userEmail)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SvgPicture.asset(
                                    'asset/images/ic_accept.svg',
                                    color: Colors.green,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),*/
                    20.heightBox,
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: accountsList.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: Key(accountsList[index]!.key!),
                            direction: DismissDirection.endToStart,
                            background: Container(),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (direction)async{
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                    Helper.getCardColor(context),
                                    title: Text(LocaleKeys.confirm.tr),
                                    content: const Text("Are you sure to delete the account?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context)
                                                .pop(false),
                                        child:
                                        Text(LocaleKeys.cancel.tr),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context)
                                                .pop(true),
                                        child:
                                        Text(LocaleKeys.delete.tr),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              final account = accountsList[index];
                              await DatabaseHelper().deleteAddedAccountFromFirebase(ownerKey, account!.key!);
                              setState(() {
                                accountsList.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account deleted')),
                              );
                            },
                            child: InkWell(
                              onTap: () {

                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: accessRequestList.isEmpty
                                        ? const BorderRadius.all(
                                            Radius.circular(10))
                                        : const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                    color: Helper.getCardColor(context)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color:
                                              Helper.getBackgroundColor(context),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: Text(
                                          Helper.getShortName(
                                              accountsList[index]!
                                                      .account_name!
                                                      .split(' ')
                                                      .first ??
                                                  "",
                                              accountsList[index]!
                                                          .account_name!
                                                          .split(' ')
                                                          .length >
                                                      1
                                                  ? accountsList[index]!
                                                      .account_name!
                                                      .split(' ')
                                                      .last
                                                  : ""),
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    20.widthBox,
                                    Expanded(
                                      child: Text(
                                        accountsList[index]!.account_name!,
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    10.widthBox,
                                    /*   InkWell(
                                      onTap: () {
                                        if (currentUserEmail !=
                                            accessRequestList[index]!
                                                .requester_email) {
                                          setState(() {
                                            currentUserEmail = userEmail;
                                          });
                                          MySharedPreferences.instance
                                              .addStringToSF(
                                              SharedPreferencesKeys
                                                  .currentUserEmail,
                                              userEmail);
                                          MySharedPreferences.instance
                                              .addStringToSF(
                                              SharedPreferencesKeys
                                                  .currentUserName,
                                              userName);


                                          MySharedPreferences.instance
                                              .addStringToSF(
                                              SharedPreferencesKeys
                                                  .currentUserKey,
                                              FirebaseAuth.instance
                                                  .currentUser!.uid);
                                        }

                                        _removeAccessRequest(
                                            accessRequestList[index]!);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    )*/
                                    if(userName == accountsList[index]!.account_name!)
                                    SvgPicture.asset(
                                      'asset/images/ic_accept.svg',
                                      color: Colors.green,
                                      height: 24,
                                      width: 24,
                                    ),
                                    10.widthBox,
                                    InkWell(
                                        onTap: (){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => AddAccountScreen(
                                                    account_name: accountsList[index]!.account_name!,
                                                    description: accountsList[index]!.description!,
                                                    budget: accountsList[index]!.budget!,
                                                    balance_date: accountsList[index]!.balance_date!,
                                                    balance: accountsList[index]!.balance!,
                                                    income: accountsList[index]!.income!,
                                                    forEditAccount: true,
                                                    account_key: accountsList[index]!.key!,
                                                    owner_user_key: accountsList[index]!.owner_user_key!,
                                                  ))).then((value) {
                                            if (value != null && value) {
                                              getAccountsList();
                                            }
                                          });
                                        },
                                        child: Icon(Icons.edit, color: Helper.getTextColor(context),))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            thickness: 0,
                            height: 10,
                            color: Colors.transparent,
                          );
                        },
                      ),
                    ),

                    ///Shared account code
                    /*  if (accessRequestList.isNotEmpty)
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
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    currentUserEmail = accessRequestList[index]!
                                        .receiver_email!;
                                  });
                                  MySharedPreferences.instance.addStringToSF(
                                      SharedPreferencesKeys.currentUserEmail,
                                      accessRequestList[index]!.receiver_email);
                                  MySharedPreferences.instance.addStringToSF(
                                      SharedPreferencesKeys.currentUserName,
                                      accessRequestList[index]!.receiver_name);

                                  MySharedPreferences.instance.addIntToSF(
                                      SharedPreferencesKeys.userAccessType,
                                      accessRequestList[index]!.accessType);

                                  final reference = FirebaseDatabase.instance
                                      .reference()
                                      .child(profile_table)
                                      .orderByChild(ProfileTableFields.email)
                                      .equalTo(currentUserEmail);

                                  reference.onValue.listen((event) {
                                    DataSnapshot dataSnapshot = event.snapshot;
                                    if (event.snapshot.exists) {
                                      Map<dynamic, dynamic> values =
                                          dataSnapshot.value
                                              as Map<dynamic, dynamic>;
                                      values.forEach((key, value) async {
                                        MySharedPreferences.instance
                                            .addStringToSF(
                                                SharedPreferencesKeys
                                                    .currentUserKey,
                                                value[ProfileTableFields.key]);
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7, horizontal: 7),
                                        decoration: BoxDecoration(
                                            color: Helper.getBackgroundColor(
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
                                              color:
                                                  Helper.getTextColor(context),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (currentUserEmail ==
                                          accessRequestList[index]!
                                              .receiver_email)
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: SvgPicture.asset(
                                              'asset/images/ic_accept.svg',
                                              color: Colors.green,
                                              height: 24,
                                              width: 24,
                                            ),
                                          ),
                                        ),
                                      10.widthBox,
                                      InkWell(
                                        onTap: () {
                                          if (currentUserEmail !=
                                              accessRequestList[index]!
                                                  .requester_email) {
                                            setState(() {
                                              currentUserEmail = userEmail;
                                            });
                                            MySharedPreferences.instance
                                                .addStringToSF(
                                                    SharedPreferencesKeys
                                                        .currentUserEmail,
                                                    userEmail);
                                            MySharedPreferences.instance
                                                .addStringToSF(
                                                    SharedPreferencesKeys
                                                        .currentUserName,
                                                    userName);


                                            MySharedPreferences.instance
                                                .addStringToSF(
                                                    SharedPreferencesKeys
                                                        .currentUserKey,
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid);
                                          }

                                          _removeAccessRequest(
                                              accessRequestList[index]!);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      )
                                    ],
                                  ),
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
                            '${LocaleKeys.requests.tr}(${requestList.length})',
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
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
                                          color: Helper.getBackgroundColor(
                                              context),
                                          borderRadius: const BorderRadius.all(
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
                                        requestList[index]!.requester_name!,
                                        style: TextStyle(
                                            color: Helper.getTextColor(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (requestList[index]!.status ==
                                        AppConstanst.pendingRequest)
                                      InkWell(
                                        onTap: () {
                                          _acceptRequest(requestList[index]!);
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
                                            _rejectRequest(requestList[index]!);
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
                                            _removeRequest(requestList[index]!);
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
                      ),*/
                  ],
                ),
              ));
  }

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;
        isLoading = false;

        ///Share account code
        // getRequestList();
      });
    } catch (error) {
      Helper.hideLoading(context);
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

/*  Future<void> getRequestList() async {
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
                accessType: value['access_type'],
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
                accessType: value['access_type'],
                status: value['status'],
                created_at: value['created_at']);
            accessRequestList.add(requestModel);
          }
        });
      }
      setState(() {});
    });
  }*/

  @override
  void initState() {
    AppConstanst.notificationClicked = false;
    MySharedPreferences.instance
        .getStringValuesSF(SharedPreferencesKeys.userName)
        .then((value) {
      if (value != null) {
        userName = value;
        MySharedPreferences.instance
            .getStringValuesSF(SharedPreferencesKeys.currentUserEmail)
            .then((value) {
          if (value != null) {
            currentUserEmail = value;
            MySharedPreferences.instance
                .getStringValuesSF(SharedPreferencesKeys.userEmail)
                .then((value) {
              if (value != null) {
                userEmail = value;
                getProfileData();
                MySharedPreferences.instance
                    .getStringValuesSF(SharedPreferencesKeys.currentUserKey)
                    .then((value) {
                  if (value != null) {
                    ownerKey = value;
                    getAccountsList();
                  }
                });
              }
            });
          }
        });
      }
    });
    super.initState();
  }

  void sendNotification(RequestModel requestModel, ProfileModel profileModel,
      bool fromAccessRequest) async {
    if (fromAccessRequest) {
      final reference = FirebaseDatabase.instance
          .reference()
          .child(profile_table)
          .orderByChild('email')
          .equalTo(requestModel.receiver_email);

      reference.once().then((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'key=AAAANkNYKio:APA91bHGQs2MllIVYtH83Lunknc7v8dXwEPlaqNKpM5u6oHIx3kNYU2VFNuYpEyVzg3hqWjoR-WzWiWMmDN8RrO1QwzEqIrGST726TgPxkp87lqbEI515NzGt7HYdCbrljuH0uldBCW8'
              },
              body: jsonEncode({
                'to': value['fcm_token'],
                'priority': 'high',
                'notification': {
                  'title': 'Hello ${requestModel.receiver_name},',
                  'body':
                      '${requestModel.requester_name} has deleted your account request',
                },
              }),
            );
          });
        }
      });
    } else {
      final reference = FirebaseDatabase.instance
          .reference()
          .child(profile_table)
          .orderByChild('email')
          .equalTo(requestModel.requester_email);

      reference.once().then((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'key=AAAANkNYKio:APA91bHGQs2MllIVYtH83Lunknc7v8dXwEPlaqNKpM5u6oHIx3kNYU2VFNuYpEyVzg3hqWjoR-WzWiWMmDN8RrO1QwzEqIrGST726TgPxkp87lqbEI515NzGt7HYdCbrljuH0uldBCW8'
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
  }

  /*_acceptRequest(RequestModel requestModel) {
    AccessType? _selectedAccessType = AccessType.viewOnly;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              title: Text(LocaleKeys.chooseAccess.tr,
                  style: TextStyle(
                      color: Helper.getTextColor(context),
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      title: Text(LocaleKeys.viewOnly.tr),
                      leading: Radio<AccessType>(
                        value: AccessType.viewOnly,
                        groupValue: _selectedAccessType,
                        onChanged: (AccessType? value) {
                          setState(() {
                            _selectedAccessType = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedAccessType = AccessType.viewOnly;
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),
                      title: Text(LocaleKeys.edit.tr),
                      leading: Radio<AccessType>(
                        value: AccessType.edit,
                        groupValue: _selectedAccessType,
                        onChanged: (AccessType? value) {
                          setState(() {
                            _selectedAccessType = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedAccessType = AccessType.edit;
                        });
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
                    TextButton(
                      onPressed: () {
                        requestModel.status = AppConstanst.acceptedRequest;
                        if (_selectedAccessType == AccessType.edit) {
                          requestModel.accessType = AppConstanst.editAccess;
                        } else {
                          requestModel.accessType = AppConstanst.viewOnlyAccess;
                        }
                        final Map<String, Map> updates = {};
                        updates['/$request_table/${requestModel.key}'] =
                            requestModel.toMap();
                        FirebaseDatabase.instance
                            .ref()
                            .update(updates)
                            .then((value) {
                          sendNotification(requestModel, profileData!, false);
                          getRequestList();
                        });

                        Navigator.of(context).pop();
                      },
                      child: Text(LocaleKeys.submit.tr),
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

  _rejectRequest(RequestModel requestModel) {
    requestModel.status = AppConstanst.rejectedRequest;

    final Map<String, Map> updates = {};
    updates['/$request_table/${requestModel.key}'] = requestModel.toMap();
    FirebaseDatabase.instance.ref().update(updates).then((value) {
      sendNotification(requestModel, profileData!, false);
      getRequestList();
    });
  }

  _removeAccessRequest(RequestModel requestModel) {
    final reference =
        FirebaseDatabase.instance.reference().child(request_table);
    reference.child(requestModel.key!).remove().then((value) {
      sendNotification(requestModel, profileData!, true);
      getRequestList();
    });
  }

  _removeRequest(RequestModel requestModel) {
    final reference =
        FirebaseDatabase.instance.reference().child(request_table);
    reference.child(requestModel.key!).remove().then((value) {
      sendNotification(requestModel, profileData!, false);
      getRequestList();
    });
  }
*/
  Future<void> getAccountsList() async {
    try {
      accountsList.clear();
      final reference = FirebaseDatabase.instance
          .reference()
          .child(accounts_table)
          .child(ownerKey);

      reference.once().then((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) async {
            AccountsModel accountsModelList = AccountsModel(
                key: key,
                owner_user_key: value['owner_user_key'],
                account_name: value['account_name'],
                description: value['description'],
                budget: value['budget'],
                balance: value['balance'],
                income: value['income'],
                balance_date: value['balance_date'],
                account_status: value['account_status'],
                created_at: value['created_at'],
                updated_at: value['updated_at']);
            setState(() {
              accountsList.add(accountsModelList);
            });
          });
        } else {
          setState(() {
            accountsList = [];
          });
        }
      });
    } catch (error) {
      print('Error fetching Account Data: $error');
    }
  }

}
