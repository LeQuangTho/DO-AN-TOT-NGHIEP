import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cahoi_barbershop/core/models/stylist/stylist.dart';
import 'package:flutter_cahoi_barbershop/core/providers/booking_provider.dart';
import 'package:flutter_cahoi_barbershop/service_locator.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/colors.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/constants.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/select_barbershop_view.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/select_service_view.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/widgets/select_stylist.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/widgets/toggle_time.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/elevated_button_icon.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/text_tag.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    model.changeCategoryServices();
    super.initState();
  }

  final model = locator<BookingProvider>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<BookingProvider>.value(
      value: model,
      child: WillPopScope(
        onWillPop: () async {
          Fluttertoast.showToast(
            msg: "Để tránh back nhầm. Hãy bấm nút back góc trên bên phải!",
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: const Text("Book a haircut"),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                padding: const EdgeInsets.all(4.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.home,
                    size: Theme.of(context).iconTheme.size ?? 24,
                  ),
                  tooltip: 'Home',
                ),
              ),
            ],
          ),
          body: Consumer<BookingProvider>(
            builder: (context, value, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              child: SizedBox(
                height: size.height,
                child: Stepper(
                  currentStep: model.currentStep.index,
                  onStepContinue: () {
                    model.nextStep();
                  },
                  onStepCancel: () {
                    model.backStep();
                  },
                  controlsBuilder: (context, details) =>
                      _buildControl(context, details),
                  steps: [
                    _buildStepSelectBarbershop(),
                    _buildStepSelectService(),
                    _buildStepSelectDateAndStylist(size),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionStylist({required Stylist stylist}) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              text: 'Stylist: ',
              style: Theme.of(context).textTheme.headline3,
              children: [
                TextSpan(
                  text: stylist.name,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline6!.color,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: '${stylist.skill} ',
              style: Theme.of(context).textTheme.headline3,
              children: [
                WidgetSpan(
                  child: RatingBarIndicator(
                    rating: stylist.skill / 5,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 1,
                    itemSize: 24.0,
                    direction: Axis.horizontal,
                  ),
                ),
                TextSpan(
                  text: " Skill",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline6!.color,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: '${stylist.communication} ',
              style: Theme.of(context).textTheme.headline3,
              children: [
                WidgetSpan(
                  child: RatingBarIndicator(
                    rating: stylist.communication / 5,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 1,
                    itemSize: 24.0,
                    direction: Axis.horizontal,
                  ),
                ),
                TextSpan(
                  text: " Communicate",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline6!.color,
                      fontFamily:
                          Theme.of(context).textTheme.headline1!.fontFamily,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSelectTime(Size size) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<BookingProvider>(builder: (context, value, child) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6,
            child: ToggleTime(
              timeStart: timeStart,
              timeEnd: timeEnd,
              duration: value.totalDuration,
              currentIndex: model.currentIndexTime,
              onPressed: (time, index) {
                value.changeSelectedTime(index, time);
              },
            ),
          );
        }),
      );

  List<Widget> _buildOptionMore(Size size, BuildContext context) {
    return [
      SizedBox(
        width: size.width,
        child: Text(
          "Notes",
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      Consumer<BookingProvider>(builder: (context, value, child) {
        return TextField(
          maxLines: 3,
          maxLength: 250,
          controller: value.notesController,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          onChanged: (_) {
            value.changeNotes();
          },
          decoration: InputDecoration(
            hintText: "EX: You go with 2 children, You go with you,"
                " Wash your hands and so on...etc",
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        );
      }),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Advice",
            style: Theme.of(context).textTheme.headline3,
          ),
          Switch(
            activeColor: primaryColor2,
            value: model.isAdvice,
            onChanged: (value) {
              model.changeAdvice(value);
            },
          )
        ],
      ),
      Text(
        "You allow us to recommend the best promotion, service for you",
        style: Theme.of(context).textTheme.subtitle2,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Take a photo after haircut",
            style: Theme.of(context).textTheme.headline3,
          ),
          Switch(
            activeColor: primaryColor2,
            value: model.isTakeAPhoto,
            onChanged: (value) {
              model.changeTakeAPhoto(value);
            },
          )
        ],
      ),
      Text(
        "You allow us to take photos to save the hairstyle,"
        " so that next time you don't have to describe it to another stylist",
        style: Theme.of(context).textTheme.subtitle2,
      ),
    ];
  }

  Widget _buildControl(BuildContext context, ControlsDetails details) {
    if (details.currentStep == StepBooking.selectBarbershop.index) {
      return Consumer<BookingProvider>(
        builder: (context, value, child) => ElevatedButtonIcon(
          title: 'Next step',
          onPressed: value.workplace == null ? null : details.onStepContinue,
        ),
      );
    } else if (details.currentStep == StepBooking.selectStylistAndDate.index) {
      return Consumer<BookingProvider>(builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
            Expanded(
              child: ElevatedButtonIcon(
                title: 'Completed',
                onPressed: model.checkCompleted()
                    ? () {
                        //Call api
                        value.complete();
                      }
                    : null,
              ),
            )
          ],
        );
      });
    } else {
      return Consumer<BookingProvider>(builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButtonIcon(
                title: 'Next Step',
                onPressed: value.selectedServices.isEmpty
                    ? null
                    : details.onStepContinue,
              ),
            ),
          ],
        );
      });
    }
  }

  Step _buildStepSelectBarbershop() => Step(
        isActive: model.currentStep == StepBooking.selectBarbershop,
        title: Text(
          "Select Barbershop",
          style: Theme.of(context).textTheme.headline2,
        ),
        state: model.workplace == null ? StepState.indexed : StepState.complete,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            model.workplace == null
                ? Container()
                : Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: TextTag(title: model.workplace!.name),
                  ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectBarbershopView(),
                    ),
                  );
                },
                child: const Text('Select Barbershop'),
              ),
            ),
          ],
        ),
      );

  Step _buildStepSelectService() => Step(
        isActive: model.currentStep == StepBooking.selectService,
        state: model.selectedServices.isEmpty
            ? StepState.indexed
            : StepState.complete,
        title: Text(
          "Select Service",
          style: Theme.of(context).textTheme.headline2,
        ),
        content: Column(
          children: [
            _buildSelectedService(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                child: const Text('Select Service'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectServiceView(
                        model: model,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Step _buildStepSelectDateAndStylist(Size size) => Step(
        isActive: model.currentStep == StepBooking.selectStylistAndDate,
        title: Text(
          "Select Stylist & Datetime",
          style: Theme.of(context).textTheme.headline2,
        ),
        state: model.checkSelectDateAndStylist()
            ? StepState.indexed
            : StepState.complete,
        content: Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                  Consumer<BookingProvider>(
                    builder: (context, value, child) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DatePicker(
                        DateTime.now(),
                        initialSelectedDate: value.selectedDate,
                        dateTextStyle: Theme.of(context).textTheme.headline2!,
                        monthTextStyle: Theme.of(context).textTheme.bodyText2!,
                        dayTextStyle: Theme.of(context).textTheme.bodyText2!,
                        daysCount: 7,
                        height: size.height * 0.115,
                        width: size.width * 0.17,
                        selectionColor: Theme.of(context)
                            .floatingActionButtonTheme
                            .backgroundColor!,
                        onDateChange: (selectedDate) {
                          value.changeSelectedDate(selectedDate);
                        },
                      ),
                    ),
                  ),
                  Consumer<BookingProvider>(
                    builder: (context, value, child) => Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      width: size.width,
                      // height: size.width * 0.26,
                      child: value.isDefaultStylist
                          ? Center(
                              child: Text(
                                "We will select help you the stylist the best",
                                style: TextStyle(
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .fontFamily,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : _buildDescriptionStylist(
                              stylist: model.stylists![model.selectedStylist]),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SelectStylist(),
                  _buildSelectTime(size),
                ] +
                _buildOptionMore(size, context),
          ),
        ),
      );

  Widget _buildSelectedService() {
    if (model.selectedServices.isEmpty) {
      return Container();
    } else {
      List<Widget> selectedServices = [];

      for (int i = 0; i < model.selectedServices.length; i++) {
        selectedServices.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextTag(title: model.selectedServices[i].name),
        ));
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Wrap(
          children: selectedServices,
        ),
      );
    }
  }

  @override
  void dispose() {
    model.reset();
    super.dispose();
  }
}
