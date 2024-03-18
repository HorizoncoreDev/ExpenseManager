import 'package:expense_manager/intro_screen/bloc/bloc.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/global.dart';
import '../utils/theme_notifier.dart';
import 'bloc/intro_bloc.dart';
import 'bloc/intro_state.dart';



class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  IntroBloc introBloc = IntroBloc();
  final List<String> texts1 = [
    'Automatic\nbackup',
    'Hidden\nassets,\nhidden\nspending',
    'Monitor\nyour wife\nspending',
    'Make a plan\nfor revenue',
    'Tips for\nsaving',
    'Manage\ndebt,\nprinciple &\ninterest',
    'Monitor\nyour\nhusband\nspending',
    'Splitting',
  ];

  final List<String> texts2 = [
    'Tips for\nsaving',
    'Manage\ndebt,\nprinciple &\ninterest',
    'Monitor\nyour\nhusband\nspending',
    'Splitting',
    'Automatic\nbackup',
    'Hidden\nassets,\nhidden\nspending',
    'Monitor\nyour wife\nspending',
    'Make a plan\nfor revenue',
  ];

  var colors = [
    Colors.red,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
  ];

  var colorsList = [
    Colors.cyan,
    Colors.green,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.cyan,
    Colors.blue,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    introBloc.context = context;
    return BlocConsumer<IntroBloc, IntroState>(
      bloc: introBloc,
      listener: (context, state) {
       /* if(state is IntroStartState){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        }*/
      },
      builder: (context, state) {
        if(state is IntroInitial){
          return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Helper.getBackgroundColor(context),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      130.heightBox,
                      SizedBox(
                        width: double.infinity,
                        height: 110,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: texts1.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              height: 110,
                              padding: const EdgeInsets.all(3),
                              alignment: Alignment.bottomLeft,
                              color: colors[index],
                              child: Text(texts1[index],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                ),),
                            );
                          },
                          separatorBuilder:
                              (BuildContext context,
                              int index) {
                            return 10.widthBox;
                          },
                        ),
                      ),
                      10.heightBox,
                      SizedBox(
                        width: double.infinity,
                        height: 110,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: texts2.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              height: 110,
                              padding: const EdgeInsets.all(3),
                              alignment: Alignment.bottomLeft,
                              color: colorsList[index],
                              child:  Text(texts2[index],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                ),),
                            );
                          },
                          separatorBuilder:
                              (BuildContext context,
                              int index) {
                            return 10.widthBox;
                          },
                        ),
                      ),

                      80.heightBox,
                      Text("Smart Expense",
                        style: TextStyle(
                            color: Helper.getTextColor(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        ),),

                      10.heightBox,
                      Text("Be a smart spender",
                        style: TextStyle(
                          color: Helper.getTextColor(context),
                          fontSize: 16,
                        ),),

                      50.heightBox,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                          decoration: BoxDecoration(
                              color: Helper.getCardColor(context),
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(ImageConstanst.icFlag),
                              15.widthBox,
                              Expanded(
                                child: Text("English",
                                  style: TextStyle(
                                      color: Helper.getTextColor(context),
                                      fontSize: 12
                                  ),),
                              ),
                              /* const Icon(Icons.arrow_forward_ios_outlined,size: 14,color: Colors.white,),*/
                            ],
                          ),
                        ),
                      ),


                      20.heightBox,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: InkWell(
                          onTap: (){
                            introBloc.add(IntroStartEvent());
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child:  const Text("Start",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),),
                          ),
                        ),
                      ),
                      10.heightBox
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


