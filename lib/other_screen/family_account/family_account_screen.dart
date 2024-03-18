import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/family_account_bloc.dart';
import 'bloc/family_account_state.dart';

class FamilyAccountScreen extends StatefulWidget {
  const FamilyAccountScreen({super.key});

  @override
  State<FamilyAccountScreen> createState() => _FamilyAccountScreenState();
}

class _FamilyAccountScreenState extends State<FamilyAccountScreen> {

  FamilyAccountBloc familyAccountBloc = FamilyAccountBloc();

  @override
  Widget build(BuildContext context) {
    familyAccountBloc.context = context;
    return BlocConsumer<FamilyAccountBloc, FamilyAccountState>(
      bloc: familyAccountBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is FamilyAccountInitial){
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 15,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.black,
                title: Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                        child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
                    Text("Family Karan",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,)),
                  ],
                ),
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                color: Colors.black,
                child: Column(
                  children: [
                    10.heightBox,
                    Row(
                      children: [
                        Expanded(
                          child: Text("Currently 2 members",
                            style: TextStyle(color: Colors.white),),
                        ),
                        RichText(
                            text: TextSpan(
                                text: "CODE: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color:Colors.blue,),
                                children: [
                                  TextSpan(
                                    text: "615739",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:Colors.blue,),),
                                ])),
                        5.widthBox,
                        Icon(Icons.qr_code_scanner,color: Colors.blue,size: 22,)
                      ],
                    ),
                    10.heightBox,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 7),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Text("MB",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),),
                                ),
                                20.widthBox,
                                Text("Muskaan Bhatt",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.black12,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 7),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Text("TP",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),),
                                ),
                                20.widthBox,
                                Expanded(
                                  child: Text("Thirali Patel",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),),
                                ),
                                Icon(Icons.arrow_circle_right_outlined,color: Colors.red,)
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    Expanded(child: Container()),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child:  const Text("Leave",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14
                        ),),
                    ),
                    30.heightBox
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }
}
