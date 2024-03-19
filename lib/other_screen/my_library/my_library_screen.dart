import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/my_library_bloc.dart';
import 'bloc/my_library_state.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {

  MyLibraryBloc myLibraryBloc = MyLibraryBloc();

  @override
  Widget build(BuildContext context) {
    myLibraryBloc.context = context;
    return BlocConsumer<MyLibraryBloc, MyLibraryState>(
      bloc: myLibraryBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is MyLibraryInitial){
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Helper.getBackgroundColor(context),
                title: Row(
                  children: [
                    InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios,color: Helper.getTextColor(context),size: 20,)),
                    10.widthBox,
                    Text("My Library",
                        style: TextStyle(
                          fontSize: 22,
                          color: Helper.getTextColor(context),)),

                  ],
                ),
              ),
              body: Container(
                color: Helper.getBackgroundColor(context),
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      20.heightBox,
                      Container(
                          decoration: BoxDecoration(
                              color:Helper.getCardColor(context),
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Column(
                            children: [
                              20.heightBox,
                              Icon(Icons.account_balance_wallet,color: Helper.getTextColor(context),size: 80,),
                              10.heightBox,
                              Text("You don't have any library yet",
                                style: TextStyle(
                                    color: Helper.getTextColor(context)
                                ),),
                              20.heightBox,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 35),
                                child: InkWell(
                                  onTap: (){
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddSpendingScreen()),
                                    );*/
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    child:  const Text("Add library",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14
                                      ),),
                                  ),
                                ),
                              ),
                              15.heightBox,
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
