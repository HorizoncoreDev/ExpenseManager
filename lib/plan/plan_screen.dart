import 'package:expense_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/plan_bloc.dart';
import 'bloc/plan_state.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  PlanBloc planBloc = PlanBloc();

  bool isHappeningSelected = true;
  int currPage = 1;

  double sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    planBloc.context = context;
    return BlocConsumer<PlanBloc, PlanState>(
      bloc: planBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is PlanInitial) {
          return Scaffold(
              appBar: AppBar(
                titleSpacing: 15,
                backgroundColor: Colors.black,
                title: RichText(
                    text: const TextSpan(
                        text: "Plan",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        children: [
                      TextSpan(
                          text: "(10/2023)",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          )),
                    ])),
                actions: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                    child: const Icon(
                      Icons.calendar_month_sharp,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  10.widthBox,
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: const Text(
                        "MB",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              body: Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    20.heightBox,
                    Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isHappeningSelected = true;
                                    currPage = 1;
                                  });
                                },
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            bottomLeft: Radius.circular(30)),
                                        color: isHappeningSelected
                                            ? Colors.blue
                                            : Colors.grey),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Happening',
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
                                    isHappeningSelected = false;
                                    currPage = 2;
                                  });
                                },
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(30),
                                            bottomRight: Radius.circular(30)),
                                        color: isHappeningSelected
                                            ? Colors.grey
                                            : Colors.blue),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Finished',
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
                    20.heightBox,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Spending limit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  ],
                                ),
                                Text(
                                  "\u20B928,700",
                                  style: TextStyle(
                                    color: Colors.pink,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        15.widthBox,
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Average Spending/day",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "\u20B9925.81",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.heightBox,
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Long press to drag or select the amount to enter",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Icon(
                          Icons.lock_open,
                          color: Colors.grey,
                          size: 20,
                        )
                      ],
                    ),
                    10.heightBox,
                    currPage == 1
                        ? Expanded(child: _happeningView(planBloc))
                        : 0.heightBox,
                    currPage == 2
                        ? Expanded(child: _finishedView(planBloc))
                        : 0.heightBox,
                  ],
                ),
              ));
        }
        return Container();
      },
    );
  }

  Widget _happeningView(PlanBloc planBloc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          Text(
                            "\u20B95,100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox
        ],
      ),
    );
  }

  Widget _finishedView(PlanBloc planBloc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Living",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\u20B95,100",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    sliderTheme: SliderThemeData(
                      thumbShape: SquareSliderComponentShape(),
                      trackShape: const MyRoundedRectSliderTrackShape(),
                    ),
                  ),
                  child: Slider(
                    onChanged: (value) => setState(() => sliderValue = value),
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    activeColor: Colors.blue,
                    inactiveColor: const Color.fromARGB(255, 230, 209, 138),
                  ),
                ),
              ],
            ),
          ),
          10.heightBox,
        ],
      ),
    );
  }
}

class SquareSliderComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 30);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    canvas.drawShadow(
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: 24, height: 20),
            const Radius.circular(4),
          )),
        Colors.black,
        5,
        false);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 20, height: 20),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.blue,
    );
  }
}

class MyRoundedRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const MyRoundedRectSliderTrackShape();

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = false,
      bool isDiscrete = false,
      double additionalTrackHeight = 8,
      required TextDirection textDirection}) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }
    /* @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    return Rect.fromLTWH(
      offset.dx,
      offset.dy, // Remove any additional offset to remove padding
      parentBox.size.width,
      sliderTheme.trackHeight!, // Use the track height directly
    );
  }*/

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius activeTrackRadius =
        Radius.circular((trackRect.height + additionalTrackHeight) / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top - (additionalTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalTrackHeight / 2),
        topLeft: activeTrackRadius,
        bottomLeft: activeTrackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        trackRect.top - (additionalTrackHeight / 2),
        trackRect.right,
        trackRect.bottom + (additionalTrackHeight / 2),
        topRight: activeTrackRadius,
        bottomRight: activeTrackRadius,
      ),
      rightTrackPaint,
    );
  }
}
