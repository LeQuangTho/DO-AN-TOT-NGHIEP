import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cahoi_barbershop/core/models/facility.dart';
import 'package:flutter_cahoi_barbershop/core/models/product.dart';
import 'package:flutter_cahoi_barbershop/core/models/stylist.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/booking_model.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/colors.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/constants.dart';
import 'package:flutter_cahoi_barbershop/ui/views/_base.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/select_facility_view.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/select_product_view.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/widgets/select_stylist.dart';
import 'package:flutter_cahoi_barbershop/ui/views/booking/widgets/time_slots.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/elevated_button_icon.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/my_date_picker_timeline.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/text_tag.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  final notesController = TextEditingController();
  Size size = Size.zero;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return BaseView<BookingModel>(
      onModelReady: (model) async {
        model.initTimeSlots();
      },
      onModelDisposed: (model) {
        model.changeDisposed();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          Fluttertoast.showToast(
            msg: "Để tránh back nhầm. Hãy bấm nút back góc trên bên phải!",
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: const Text("Đặt lịch cắt tóc"),
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
          body: Theme(
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
                    _buildControl(context, details, model),
                steps: [
                  _buildStepSelectFacility(
                    currentStep: model.currentStep,
                    currrentFacility: model.selectedFacility,
                    onPressSelect: () async {
                      var result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SelectFacilityView(),
                        ),
                      );

                      if (result != null && result.containsKey('selection')) {
                        model.changeSelectedFacility(result['selection']);
                      }
                    },
                  ),
                  _buildStepSelectProduct(
                    currentStep: model.currentStep,
                    selectedProducts: model.selectedProducts,
                    onPressSelectProduct: () async {
                      var result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SelectProductView(
                            model: model,
                          ),
                        ),
                      );

                      if (result != null && result['services'] != null) {
                        model.updateSelectedProduct(result['services']);
                      }
                    },
                  ),
                  _buildStepSelectDateAndStylist(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControl(
      BuildContext context, ControlsDetails details, BookingModel model) {
    if (details.currentStep == StepBooking.selectFacility.index) {
      return ElevatedButtonIcon(
        title: 'Bước tiếp theo',
        onPressed:
            model.selectedFacility == null ? null : details.onStepContinue,
      );
    } else if (details.currentStep == StepBooking.selectStylistAndDate.index) {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Trở lại'),
            ),
          ),
          Expanded(
            child: ElevatedButtonIcon(
              title: 'Hoàn tất',
              onPressed: model.checkCompleted()
                  ? () async {
                      var res =
                          await model.complete(notes: notesController.text);
                      if (res) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.SUCCES,
                          title: "Đặt lịch thành công",
                          btnOkOnPress: () {
                            Navigator.pop(context);
                          },
                        ).show();
                      } else {
                        AwesomeDialog(
                          context: context,
                          title: "Đã có sự cố, vui lòng thử lại sau! 🥲🥲🥲",
                          dialogType: DialogType.ERROR,
                          btnOkOnPress: () {},
                        ).show();
                      }
                    }
                  : null,
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Trở lại'),
            ),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButtonIcon(
              title: 'Bước tiếp theo',
              onPressed: model.selectedProducts.isEmpty
                  ? null
                  : details.onStepContinue,
            ),
          ),
        ],
      );
    }
  }

  Step _buildStepSelectFacility({
    required StepBooking currentStep,
    required Facility? currrentFacility,
    required Function() onPressSelect,
  }) =>
      Step(
        isActive: currentStep == StepBooking.selectFacility ||
            currrentFacility != null,
        title: const Text(
          "Chọn cơ sở",
          style: TextStyle(
            color: textColorLight2,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: fontBold,
          ),
        ),
        state:
            currrentFacility == null ? StepState.indexed : StepState.complete,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currrentFacility == null)
              Container()
            else
              Container(
                height: size.width * 0.3,
                width: size.width * 0.8,
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Card(
                  color: backgroundColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            '$localHost${currrentFacility.image}',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${currrentFacility.address}",
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressSelect,
                child: const Text('Chọn cơ sở'),
              ),
            ),
          ],
        ),
      );

  Step _buildStepSelectProduct({
    required StepBooking currentStep,
    required List<Product> selectedProducts,
    required Function() onPressSelectProduct,
  }) =>
      Step(
        isActive: currentStep == StepBooking.selectProduct ||
            selectedProducts.isNotEmpty,
        state:
            selectedProducts.isEmpty ? StepState.indexed : StepState.complete,
        title: const Text(
          "Chọn dịch vụ",
          style: TextStyle(
            color: textColorLight2,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: fontBold,
          ),
        ),
        content: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Wrap(
                children: _buildSelectedProduct(
                  selectedProducts: selectedProducts,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                child: const Text('Chọn dịch vụ'),
                onPressed: onPressSelectProduct,
              ),
            ),
          ],
        ),
      );

  Step _buildStepSelectDateAndStylist(BookingModel model) => Step(
        isActive: model.currentStep == StepBooking.selectStylistAndDate,
        title: const Text(
          "Chọn thợ cắt tóc & ngày, giờ",
          style: TextStyle(
            color: textColorLight2,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: fontBold,
          ),
        ),
        state: model.checkCompleted() ? StepState.complete : StepState.editing,
        content: Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyDatePickerTimeline(
                DateTime.now(),
                initialSelectedDate: model.selectedDate,
                daysCount: 7,
                height: size.height * 0.117,
                width: size.width * 0.17,
                selectedTextColor: Colors.white,
                selectionColor: secondaryColor,
                dateTextStyle: const TextStyle(
                  fontSize: 12,
                ),
                dayTextStyle: const TextStyle(
                  fontSize: 12,
                ),
                onDateChange: (selectedDate) {
                  model.changeSelectedDate(selectedDate);
                },
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                width: size.width,
                height: 100,
                child: _buildDescriptionStylist(
                  stylist: model.selectedStylist,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SelectStylist(
                onSelected: (stylist) {
                  model.changeSelectedStylist(stylist);
                },
                current: model.selectedStylist,
                stylists: model.stylists ?? [],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: size.width,
                  height: size.height * 0.15,
                  child: TimeSlots(
                    currentTimeSlot: model.currentTimeSlot,
                    onPressed: (timeSlot) {
                      model.changeCurrentTimeSlot(timeSlot: timeSlot);
                    },
                    timeSlots: model.timeSlotsDefault,
                    selectedDate: model.selectedDate,
                  ),
                ),
              ),
              SizedBox(
                width: size.width,
                child: const Text(
                  "Ghi chú",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: fontBold,
                  ),
                ),
              ),
              TextField(
                maxLines: 3,
                maxLength: 250,
                controller: notesController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Ví dụ: Anh đi với 2 đứa con, Anh đi với bạn, "
                      "Rửa tay và vân vân ... vv",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildDescriptionStylist({
    required StylistRate? stylist,
  }) {
    return stylist == null
        ? const Center(
            child: Text(
              "Chúng tôi sẽ chọn giúp bạn thợ tốt nhất..",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  "Stylist: ${stylist.name ?? ""}",
                  style: TextStyle(
                    fontFamily: fontBold,
                    shadows: [
                      Shadow(
                        color: Colors.grey.shade500,
                        offset: const Offset(0, 0),
                        blurRadius: 5,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text("Giao tiếp: ${stylist.communication ?? '5'}"),
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text("Kĩ năng: ${stylist.skill ?? '5'}"),
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  List<Widget> _buildSelectedProduct(
      {required List<Product> selectedProducts}) {
    List<Widget> items = [];
    double price = 0;
    for (int i = 0; i < selectedProducts.length; i++) {
      price += selectedProducts[i].price;

      items.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextTag(
            product: selectedProducts[i],
          ),
        ),
      );
    }

    ///Add item total
    items.add(Container(
      height: 40,
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Tổng: ",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: primaryColor, fontSize: 20, fontFamily: fontBold),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: Colors.yellow,
            ),
            child: Text(
              "${price}K",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black26),
      ),
    ));
    return items;
  }
}
