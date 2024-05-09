import 'package:expense_manager/db_models/profile_model.dart';
import 'package:expense_manager/db_models/request_model.dart';
import 'package:expense_manager/db_service/database_helper.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/global.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  Future<void> getProfileData() async {
    try {
      ProfileModel? fetchedProfileData =
          await databaseHelper.getProfileData(userEmail);
      setState(() {
        profileData = fetchedProfileData;
        isLoading = false;
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
    requestList=[];
    await databaseHelper.getRequestData(profileData!.email!).then((value) {
      if (value != null) {
        setState(() {
          requestList.addAll(value.where((item) => item!.status != AppConstanst.rejectedRequest));
        });
      }
    });
  }

  @override
  void initState() {
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
              body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                color: Helper.getBackgroundColor(context),
                child: Column(
                  children: [
                    10.heightBox,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            requestList.isNotEmpty
                                ? "Currently ${1 + requestList.length} members"
                                : "Currently 1 member",
                            style:
                                TextStyle(color: Helper.getTextColor(context)),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Helper.getCardColor(context),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
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
                          if (requestList.isNotEmpty)
                            const Divider(
                              thickness: 1,
                              color: Colors.black12,
                            ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: requestList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
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
                                        onTap: (){
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
                                          onTap: (){
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
                              onTap: (){
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
                                color: Colors.black12,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    /* Expanded(child: Container()),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: const Text(
                        "Leave",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),*/
                    15.heightBox
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }

  _acceptRequest(RequestModel requestModel){
    requestModel.status = AppConstanst.acceptedRequest;
    DatabaseHelper.instance.updateRequestData(requestModel).then((value) => getRequestList());
  }

  _rejectRequest(RequestModel requestModel){
    requestModel.status = AppConstanst.rejectedRequest;
    DatabaseHelper.instance.updateRequestData(requestModel).then((value) => getRequestList());
  }
  
  _removeRequest(RequestModel requestModel){
    DatabaseHelper.instance.deleteRequest(requestModel).then((value) => getRequestList());
  }

}
