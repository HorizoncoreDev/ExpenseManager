import 'dart:ui';

import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../db_models/category_model.dart';
import '../../../db_models/income_category.dart';
import '../../../db_service/database_helper.dart';
import '../../../utils/views/custom_text_form_field.dart';
import 'bloc/add_category_bloc.dart';
import 'bloc/add_category_state.dart';

class AddCategoryScreen extends StatefulWidget {

  final int currPage;

  const AddCategoryScreen({super.key,required this.currPage});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

  AddCategoryBloc addCategoryBloc = AddCategoryBloc();

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.grey,
    Colors.blueGrey,
    Colors.white,
  ];

  TextEditingController nameController = TextEditingController();

  List<String> myCategoriesIcons = ['ic_google', 'ic_facebook', 'ic_apple','ic_google', 'ic_facebook', 'ic_apple'];
  String iconSelected = '';
  Color? isSelectedColor;

  Future<void> _onSave() async {
    final name = nameController.text;

    // Add save code here
    await databaseHelper.insertCategory(
      Category(name: name, color: isSelectedColor!,icons: iconSelected),
    );

    Navigator.pop(context,true);
  }

  Future<void> _onIncomeSave() async {
    final name = nameController.text;

    // Add save code here
    await databaseHelper.insertIncomeCategory(
      IncomeCategory(name: name, parentId: 1, path: iconSelected, status: 1, color: isSelectedColor!),
    );

    Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    addCategoryBloc.context = context;
    return BlocConsumer<AddCategoryBloc, AddCategoryState>(
      bloc: addCategoryBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is AddCategoryInitial){
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.black87,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text("Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),),
                    ),
                    const Text("Add category",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: (){
                        if(widget.currPage == 1){
                          _onSave();
                        }else{
                          _onIncomeSave();
                        }
                      },
                      child: Text("Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),),
                    ),
                  ],
                ),
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("NAME",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14
                          ),),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red
                          ),
                          child: const Icon(
                            Icons.question_mark,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),

                    10.heightBox,
                    CustomBoxTextFormField(
                        controller: nameController,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(8)),
                        keyboardType: TextInputType.text,
                        fillColor: Colors.white10,
                        borderColor: Colors.transparent,
                        padding: 10 ,
                        horizontalPadding: 5,
                        validator: (value) {
                          return null;
                        }),

                    20.heightBox,
                    Text("COLOR",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14
                      ),),

                    5.heightBox,
                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: colors.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              setState(() {
                                isSelectedColor = colors[index];
                                print("Selected color is $isSelectedColor");
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration:  BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors[index]
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return 10.widthBox;
                        },
                      ),
                    ),

                    20.heightBox,
                    Text("ICON",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14
                      ),),

                    5.heightBox,
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color(0xff29292d),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 2 / 1,
                            mainAxisSpacing: 4
                          ),
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: myCategoriesIcons.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    iconSelected = myCategoriesIcons[index];
                                  });
                                },
                                  child: SvgPicture.asset('asset/images/${myCategoriesIcons[index]}.svg',color: Color(0xff86859a))),
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

}
