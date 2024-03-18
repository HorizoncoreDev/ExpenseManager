import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/select_account_bloc.dart';
import 'bloc/select_account_state.dart';

class SelectAccountScreen extends StatefulWidget {
  const SelectAccountScreen({super.key});

  @override
  State<SelectAccountScreen> createState() => _SelectAccountScreenState();
}

class _SelectAccountScreenState extends State<SelectAccountScreen> {

  SelectAccountBloc selectAccountBloc = SelectAccountBloc();

  @override
  Widget build(BuildContext context) {
    selectAccountBloc.context = context;
    return BlocConsumer<SelectAccountBloc, SelectAccountState>(
      bloc: selectAccountBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is SelectAccountInitial){
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 15,
                backgroundColor: Colors.black,
                title: Row(
                  children: [
                    Icon(Icons.arrow_back_ios,color: Colors.white,size: 20,),
                    Text("Select an account",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,)),
                  ],
                ),
              ),
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:   [
                    10.heightBox,
                    const Text("You can switch back to your current account anytime",
                      style: TextStyle(color: Colors.white70),),
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
                            padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Muskaan Bhatt",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),),
                                      Text("muskanbhatt12@gmail.com",
                                        style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_circle_right,color: Colors.greenAccent,)
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.black12,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Thirali Patel",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),),
                                      Text("thirali.patel@horizoncore.com",
                                        style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.black12,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child:Icon(Icons.family_restroom_sharp,color: Colors.blue,),
                                ),
                                20.widthBox,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("My family",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),),
                                      Text("Currently 2 members",
                                        style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    30.heightBox,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child:  const Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14
                        ),),
                    ),
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }
}
