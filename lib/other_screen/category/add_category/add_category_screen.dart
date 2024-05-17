import 'package:expense_manager/utils/extensions.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../db_models/expense_category_model.dart';
import '../../../db_models/income_category.dart';
import '../../../db_service/database_helper.dart';
import '../../../utils/views/custom_text_form_field.dart';

class AddCategoryScreen extends StatefulWidget {
  final int currPage;

  const AddCategoryScreen({super.key, required this.currPage});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;

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

  List<String> myCategoriesIcons = [
    'ic_bicycle',
    'ic_car',
    'ic_flight',
    'ic_movie',
    'ic_card',
    'ic_train',
    'ic_commute',
    'ic_coupon',
    'ic_dine_out',
    'ic_enjoyment',
    'ic_equity',
    'ic_health',
    'ic_insurance',
    'ic_gym',
    'ic_part_time_work',
    'ic_pension',
    'ic_skate',
    'ic_salary',
    'ic_shopping',
    'ic_sunglasses',
  ];
  String iconSelected = '';
  Color? isSelectedColor;

  Future<void> _onSave() async {
    final name = nameController.text;

    // Add save code here
    await databaseHelper.insertCategory(
      ExpenseCategory(name: name, color: isSelectedColor!, icons: iconSelected),
    );

    Navigator.pop(context, true);
  }

  Future<void> _onIncomeSave() async {
    final name = nameController.text;

    await databaseHelper.insertIncomeCategory(
      IncomeCategory(
          name: name,
          parentId: 1,
          path: iconSelected,
          status: 1,
          color: isSelectedColor!),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Helper.getBackgroundColor(context),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  LocaleKeys.back.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 16),
                ),
              ),
              Text(LocaleKeys.addCategory.tr,
                  style: TextStyle(
                      fontSize: 22,
                      color: Helper.getTextColor(context),
                      fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () {
                  if (widget.currPage == 1) {
                    _onSave();
                  } else {
                    _onIncomeSave();
                  }
                },
                child: Text(
                  LocaleKeys.done.tr,
                  style: TextStyle(
                      color: Helper.getTextColor(context), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Helper.getBackgroundColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.name.tr,
                    style: TextStyle(
                        color: Helper.getTextColor(context), fontSize: 14),
                  ),
                ],
              ),
              10.heightBox,
              CustomBoxTextFormField(
                  controller: nameController,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  keyboardType: TextInputType.text,
                  fillColor: Helper.getCardColor(context),
                  borderColor: Colors.transparent,
                  padding: 10,
                  textStyle: TextStyle(
                    color: Helper.getTextColor(context),
                  ),
                  horizontalPadding: 5,
                  validator: (value) {
                    return null;
                  }),
              20.heightBox,
              Text(
                LocaleKeys.color.tr,
                style: TextStyle(
                    color: Helper.getTextColor(context), fontSize: 14),
              ),
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
                      onTap: () {
                        setState(() {
                          isSelectedColor = colors[index];
                        });
                      },
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: colors[index]),
                            ),
                            if (isSelectedColor == colors[index])
                              const Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.black,
                                  ))
                          ],
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
              Text(
                LocaleKeys.icon.tr,
                style: TextStyle(
                    color: Helper.getTextColor(context), fontSize: 14),
              ),
              5.heightBox,
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Helper.getCardColor(context),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.7,
                            mainAxisSpacing: 5),
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: myCategoriesIcons.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                iconSelected = myCategoriesIcons[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      iconSelected == myCategoriesIcons[index]
                                          ? Colors.blue
                                          : Colors.transparent),
                              child: SvgPicture.asset(
                                'asset/images/${myCategoriesIcons[index]}.svg',
                                color: iconSelected == myCategoriesIcons[index]
                                    ? Colors.white
                                    : const Color(0xff86859a),
                                height: 1,
                                width: 1,
                              ),
                            )),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
