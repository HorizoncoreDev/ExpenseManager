import 'package:expense_manager/other_screen/category/sub_category_screen/sub_category_screen.dart';
import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../db_models/category_model.dart';
import '../../db_models/income_category.dart';
import '../../db_service/database_helper.dart';
import 'add_category/add_category_screen.dart';
import 'bloc/category_bloc.dart';
import 'bloc/category_state.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  CategoryBloc categoryBloc = CategoryBloc();

  int currPage = 1;

  DatabaseHelper helper = DatabaseHelper();
  final databaseHelper = DatabaseHelper.instance;


  List<Category> categories = [];
  bool isLoading = true;
  bool isIncomeLoading = true;

  Future<void> getSpendingCategorys() async {
    try {
      // Simulating asynchronous database fetching
      await Future.delayed(const Duration(seconds: 2));
      List<Category> fetchedCategories = await databaseHelper.categorys();
      setState(() {
        // Update the state with the fetched categories.
        categories = fetchedCategories;
        isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (error) {
      print('Error fetching categories: $error');
      setState(() {
        isLoading = false; // Set loading state to false on error
      });
    }
  }

  List<IncomeCategory> incomeCategories = [];

  Future<void> getIncomeCategorys() async {
    try {
      // Simulating asynchronous database fetching
      await Future.delayed(const Duration(seconds: 2));
      List<IncomeCategory> fetchedIncomeCategories = await databaseHelper.getIncomeCategory();
      setState(() {
        // Update the state with the fetched categories.
        incomeCategories = fetchedIncomeCategories;
        isIncomeLoading = false; // Set loading state to false when data is fetched
      });
    } catch (error) {
      print('Error fetching categories: $error');
      setState(() {
        isIncomeLoading = false; // Set loading state to false on error
      });
    }
  }




  @override
  void initState() {
    super.initState();
    // Fetch categories when the widget is first initialized.
    getSpendingCategorys();

  }



  @override
  Widget build(BuildContext context) {
    categoryBloc.context = context;
    return BlocConsumer<CategoryBloc, CategoryState>(
      bloc: categoryBloc,
      listener: (context, state) {
      },
      builder: (context, state) {
        if(state is CategoryInitial){
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.black87,
                title: Row(
                  children: [
                    InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios,color: Colors.white,size: 20,)),
                    10.widthBox,
                    Text("Category",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,)),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: (){
                      if(currPage == 1){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCategoryScreen(currPage: 1,))
                        ).then((value) {
                          if (value) {
                            getSpendingCategorys();
                          }
                        });
                      }
                      else{
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCategoryScreen(currPage: 2,))
                        ).then((value) {
                          if (value) {
                            getIncomeCategorys();
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  10.widthBox,
                ],
              ),
              body: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black87,
                child: Column(
                  children: [
                    20.heightBox,
                    Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    currPage = 1;
                                  });
                                },
                                child:  Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft:Radius.circular(30),
                                              bottomLeft: Radius.circular(30)),
                                          color: currPage == 1
                                              ? Colors.blue
                                              : Colors.white10),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Spending',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    currPage = 2;
                                    getIncomeCategorys();
                                  });

                                },
                                child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topRight:Radius.circular(30),
                                              bottomRight: Radius.circular(30)),
                                          color: currPage == 2
                                              ? Colors.blue
                                              : Colors.white10),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Income',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),

                              ),
                            ),
                          ],
                        )),

                    currPage == 1
                        ? Expanded(
                        child:_happeningView(categoryBloc))
                        : 0.heightBox,

                    currPage == 2
                        ? Expanded(
                        child:_finishedView(categoryBloc))
                        : 0.heightBox,

                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }


  Widget _happeningView(CategoryBloc categoryBloc) {
    return  isLoading
        ? Center(child: CircularProgressIndicator())
        :categories.isEmpty
        ? Center(child: Text('No categories found.'))
        :SingleChildScrollView(
      child: Column(
        children: [
          20.heightBox,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child:ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SubCategoryScreen(categoryName: categories[index].name!,categoryId: categories[index].id!,currPage: 1,))
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: SvgPicture.asset('asset/images/${categories[index].icons}.svg',
                                          color: categories[index].color,
                                      width: 24,
                                      height: 24,),
                                    ),
                                    20.widthBox,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(categories[index].name.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),),
                                          /*Text("",
                                            style: TextStyle(color: Colors.white),),*/
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              thickness: 0.3,
                              color: Colors.grey,
                            );
                          },
                        )

             /* Column(
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                ],
              ),*/
            ),
          ),
        ],
      ),
    );
  }

  Widget _finishedView(CategoryBloc categoryBloc) {
    return  isIncomeLoading
        ? Center(child: CircularProgressIndicator())
        :incomeCategories.isEmpty
        ? Center(child: Text('No categories found.'))
        :SingleChildScrollView(
      child: Column(
        children: [
          20.heightBox,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child:ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incomeCategories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SubCategoryScreen(categoryName: incomeCategories[index].name!,categoryId: incomeCategories[index].id!,currPage: 2,))
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: SvgPicture.asset('asset/images/${incomeCategories[index].path}.svg',
                                  color: incomeCategories[index].color,
                                width: 24,
                                height: 24,),
                            ),
                            20.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(incomeCategories[index].name.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),),
                                  /*Text("7 subcategories",
                                    style: TextStyle(color: Colors.white),),*/
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      thickness: 0.3,
                      color: Colors.grey,
                    );
                  },
                )

              /* Column(
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.3,
                    color: Colors.grey,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Icon(Icons.cake,color: Colors.blue,),
                        ),
                        20.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dine out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),),
                              Text("7 subcategories",
                                style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,size: 18,)
                      ],
                    ),
                  ),
                ],
              ),*/
            ),
          ),
        ],
      ),
    );
  }
}
