
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../db_models/profile_model.dart';
import '../../db_service/database_helper.dart';
import '../../utils/theme_notifier.dart';
import '../../utils/views/custom_text_form_field.dart';
import 'bloc/edit_account_detail_bloc.dart';
import 'bloc/edit_account_detail_state.dart';
import 'package:provider/provider.dart';

class EditAccountDetailScreen extends StatefulWidget {
  const EditAccountDetailScreen({super.key});

  @override
  State<EditAccountDetailScreen> createState() => _EditAccountDetailScreenState();
}

class _EditAccountDetailScreenState extends State<EditAccountDetailScreen> {

  EditAccountDetailBloc editAccountDetailBloc = EditAccountDetailBloc();

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? dateOfBirth;
  String dob = "";

  String selectedValue = 'Female';
  List<String> dropdownItems = ['Male', 'Female'];

  bool emailIsValid = false;
  String shortName = "";
  bool isLoading = true;

  List<ProfileModel> profileData = [];

  bool validateEmail(String email) {
    RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$");
    return emailRegex.hasMatch(email);
  }

  String getShortName(String name, String name1) {

    String firstStr = name.split(" ").first;
    String secondStr = name1.split(" ").first;

    String firstChar = firstStr.substring(0, 1);
    String secondChar = secondStr.substring(0, 1);

    return shortName = firstChar + secondChar;
  }

  Future<void> getProfileData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      List<ProfileModel> fetchedProfileData = await databaseHelper.getProfileData();
      setState(() {
        profileData = fetchedProfileData;

        firstNameController.text = profileData[0].first_name!;
        lastNameController.text = profileData[0].last_name!;
        emailController.text = profileData[0].email!;
        dob = profileData[0].dob!;
        selectedValue = profileData[0].gender==""?'Female':profileData[0].gender!;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching Profile Data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfileData() async {
    await databaseHelper.updateProfileData(
      ProfileModel(id: 0,
          first_name: firstNameController.text,
                   last_name: lastNameController.text,
                   email: emailController.text,
                   dob: dateOfBirth == null
                       ? "Select DOB"
                       : dateOfBirth!,
                   gender: selectedValue,
      full_name: "",
      profile_image: "",
      mobile_number: ""),
    );
    getProfileData();
  }

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    editAccountDetailBloc.context = context;
    return BlocConsumer<EditAccountDetailBloc, EditAccountDetailState>(
      bloc: editAccountDetailBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is EditAccountDetailInitial){
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                leadingWidth: 80,
                automaticallyImplyLeading: false,
                backgroundColor: themeNotifier.getTheme().backgroundColor,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,)),
                      ),
                    ],
                  ),
                ),
                title: const Text("Account details",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,)),
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                height: double.infinity,
                color: themeNotifier.getTheme().backgroundColor,
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                :SingleChildScrollView(
                  child: Column(
                    children: [
                      15.heightBox,
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: Container(padding: const EdgeInsets.all(3),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueGrey,
                            ),
                            child: Text(shortName,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),),
                          ),
                        ),
                      ),

                      20.heightBox,
                      CustomBoxTextFormField(
                          controller: firstNameController,
                          keyboardType: TextInputType.text,
                          hintText: "Enter First Name",
                          hintColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                          borderRadius: BorderRadius.circular(10),
                          borderColor: Colors.white,
                          fillColor: Colors.white24,
                          prefixIcon: const Icon(Icons.person_2_outlined,color: Colors.blue,),
                          suffixIcon: firstNameController.text.isNotEmpty
                        ?InkWell(
                            onTap: (){
                              setState(() {
                                FocusScope.of(
                                    context)
                                    .unfocus();
                                firstNameController
                                    .clear();
                              });
                            },
                              child: const Icon(Icons.cancel,color: Colors.grey,)):0.widthBox,
                        onChanged: (value){
                          setState(() {
                            getShortName(firstNameController.text,lastNameController.text);
                          });
                        },
                          validator: (value) {
                            return null;
                          },
                        ),
                      20.heightBox,
                      CustomBoxTextFormField(
                        controller: lastNameController,
                        keyboardType: TextInputType.text,
                        hintText: "Enter Last Name",
                        hintColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                        borderRadius: BorderRadius.circular(10),
                        borderColor: Colors.white,
                        fillColor: Colors.white24,
                        prefixIcon: const Icon(Icons.person_2_outlined,color: Colors.blue,),
                        suffixIcon: lastNameController.text.isNotEmpty
                            ?InkWell(
                          onTap: (){
                            setState(() {
                              FocusScope.of(
                                  context)
                                  .unfocus();
                              lastNameController
                                  .clear();
                            });
                          },
                            child: const Icon(Icons.cancel,color: Colors.grey,))
                        :0.widthBox,
                        onChanged: (value){
                          setState(() {
                            getShortName(firstNameController.text,lastNameController.text);
                          });
                        },
                        validator: (value) {
                          return null;
                        },
                      ),
                      20.heightBox,
                      CustomBoxTextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.text,
                        hintText: "Enter Email",
                        hintColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                        borderRadius: BorderRadius.circular(10),
                        borderColor: Colors.white,
                        fillColor: Colors.white24,
                        prefixIcon: const Icon(Icons.email_outlined,color: Colors.blue,),
                        suffixIcon: emailIsValid
                        ?const Icon(Icons.verified,color: Colors.green,)
                        :0.widthBox,
                          onChanged: (value){
                          setState(() {
                            bool isValid = validateEmail(value.toString());
                            emailIsValid = isValid;
                          });
                          },
                        validator: (value) {
                          return null;
                        },
                      ),
                      20.heightBox,
                      InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.blue,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue, // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101));
                          if (pickedDate != null) {
                            String formattedDate =
                            DateFormat("yMMMd").format(pickedDate);
                            dateOfBirth = formattedDate;
                            dob = DateFormat("yyyy-MM-dd").format(pickedDate);
                            setState(() {

                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                              )),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_sharp,color: Colors.blue,size: 18,),
                              10.widthBox,
                              Text(
                                dateOfBirth == null
                                    ? "Select DOB"
                                    : dateOfBirth!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,),
                              ),
                            ],
                          ),
                        ),
                      ),
                      20.heightBox,
                      Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Colors.white10,
                              border: Border.all(
                                  color: Colors.white),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownElevation: 2,
                                      buttonDecoration: const BoxDecoration(
                                          color: Colors.white24),
                                      dropdownDecoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          color: Colors.white24),
                                      customButton: Container(
                                          color: Colors.white24,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 10),
                                          child: Row(
                                            children: [
                                              Icon(selectedValue == "Male"
                                                ?Icons.male:Icons.female,
                                                color: Colors.blue,
                                              ),
                                              8.widthBox,
                                              Expanded(
                                                child: Text(
                                                    selectedValue,
                                                    textAlign:
                                                    TextAlign.start,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white)),
                                              ),
                                              const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.grey,
                                              )
                                            ],
                                          )),
                                      items: dropdownItems
                                          .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ))
                                          .toList(),
                                      dropdownMaxHeight: 200,
                                      offset: const Offset(0, -1),
                                      value: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          var val = value as String;
                                          selectedValue = val;
                                        });
                                      },
                                      iconSize: 28,
                                      buttonPadding: EdgeInsets.zero,
                                      buttonHeight: 40,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )),
                            ],
                          )),

                       (MediaQuery.of(context).size.height / 5).heightBox,
                      InkWell(
                        onTap: (){
                          setState(() {
                            updateProfileData();
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child:  const Text("Update",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                            ),),
                        ),
                      ),
                      30.heightBox,
                    ],
                  ),
                ),
              ));
        }
        return Container();
      },
    );
  }
}
