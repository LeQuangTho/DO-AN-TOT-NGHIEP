import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cahoi_barbershop/core/models/type_product_2.dart';
import 'package:flutter_cahoi_barbershop/core/services/booking_service.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/admin_model/product_model.dart';
import 'package:flutter_cahoi_barbershop/service_locator.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/constants.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/style.dart';
import 'package:flutter_cahoi_barbershop/ui/views/_base.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/button_login.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/dialogs/loading_dialog.dart';
import 'package:flutter_cahoi_barbershop/ui/widgets/dialogs/success_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({Key? key}) : super(key: key);

  static String name = 'add-product';

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  late Size size;
  PickedFile? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController sortDController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  FixedExtentScrollController typeProductController =
      FixedExtentScrollController();

  final typeProducts = locator<BookingService>().typeProducts;
  int _selectedTime = 0;
  late TypeProduct2 _selectedTypeProduct;

  @override
  void initState() {
    _selectedTypeProduct = typeProducts.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return BaseView<ProductModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 200),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  showMenuPick();
                },
                child: image == null
                    ? Container(
                        height: size.width,
                        width: size.width,
                        child: const Icon(Icons.camera_alt),
                        decoration: BoxDecoration(color: Colors.grey.shade400),
                      )
                    : SizedBox(
                        height: size.width,
                        width: size.width,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(image?.path ?? ""),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                            const Positioned(
                              bottom: 20,
                              right: 20,
                              child: Icon(
                                Icons.edit,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "T??n d???ch v???",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        label: const Text("T??n d???ch v???"),
                      ),
                      maxLength: 100,
                    ),
                    TextField(
                      controller: sortDController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "M?? t??? ng???n",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        label: const Text("M?? t??? ng???n"),
                      ),
                      maxLines: 4,
                      maxLength: 250,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "M?? t??? chi ti???t",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        label: const Text("M?? t??? chi ti???t"),
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Th???i gian kho???ng:",
                            style: TextStyle(
                              fontFamily: fontBold,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 5,
                            child: CupertinoPicker.builder(
                              childCount: 121,
                              itemBuilder: (context, index) => Center(
                                child: Text(
                                  "$index ph??t",
                                ),
                              ),
                              itemExtent: 30.0,
                              onSelectedItemChanged: (selectedItem) {
                                setState(() {
                                  _selectedTime = selectedItem;
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Lo???i d???ch v???:",
                            style: TextStyle(
                              fontFamily: fontBold,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 7,
                            child: CupertinoPicker.builder(
                              scrollController: typeProductController,
                              childCount: typeProducts.length,
                              itemBuilder: (context, index) => Center(
                                child: Text(
                                  "${typeProducts[index].name}",
                                ),
                              ),
                              itemExtent: 30.0,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedTypeProduct = typeProducts[index];
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Gi??",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        label: const Text("Gi??"),
                        suffixStyle: const TextStyle(
                          fontFamily: fontBold,
                        ),
                        suffixText: "K",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: BaseButton(
          height: 50,
          width: size.width * 0.8,
          onPressed: () async {
            LoadingDialog.show(context);

            if (image == null) {
              Fluttertoast.showToast(msg: "Ch??a th??m ???nh");
              return;
            }
            if (sortDController.text.isEmpty ||
                descriptionController.text.isEmpty ||
                nameController.text.isEmpty ||
                priceController.text.isEmpty) {
              Fluttertoast.showToast(msg: "H??y ??i???n ?????y ????? th??ng tin!");
              return;
            }
            if (image == null) {
              Fluttertoast.showToast(msg: "Ch??a th??m ???nh");
              return;
            }

            Map<String, dynamic> data = {
              "name": nameController.text,
              "sort_description": sortDController.text,
              "description": descriptionController.text,
              "duration": _selectedTime,
              "price": double.parse(priceController.text),
              "type_product_id": _selectedTypeProduct.id
            };

            if (await model.createProduct(
              data: data,
              image: image!,
            )) {
              LoadingDialog.dismiss(context);
              SuccessDialog.show(
                context,
                btnOkOnPress: () {
                  Navigator.pop(context, true);
                },
              );
            } else {
              LoadingDialog.dismiss(context);
              Fluttertoast.showToast(msg: '???? c?? s??? c??? s???y ra!');
            }
          },
          title: "Th??m",
        ),
      ),
    );
  }

  void showMenuPick() {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildChooseCamera(
                icon: const Icon(
                  Icons.camera,
                  color: Colors.grey,
                ),
                onTap: () async {
                  var imagePicked =
                      // ignore: invalid_use_of_visible_for_testing_member
                      await ImagePicker.platform.pickImage(
                    source: ImageSource.camera,
                    maxHeight: 1080,
                    maxWidth: 1080,
                  );

                  if (imagePicked != null) {
                    setState(() {
                      image = imagePicked;
                    });
                  }
                },
                label: 'Camera',
              ),
              const SizedBox(
                width: 10,
              ),
              _buildChooseCamera(
                icon: const Icon(
                  Icons.collections_sharp,
                  color: Colors.grey,
                ),
                onTap: () async {
                  var imagePicked =
                      // ignore: invalid_use_of_visible_for_testing_member
                      await ImagePicker.platform.pickImage(
                    maxHeight: 1080,
                    maxWidth: 1080,
                    source: ImageSource.gallery,
                  );
                  if (imagePicked != null) {
                    setState(() {
                      image = imagePicked;
                    });
                  }
                  Navigator.pop(context);
                },
                label: 'Th?? vi???n',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChooseCamera(
      {Function()? onTap, required Icon icon, required String label}) {
    return Expanded(
      child: InkWell(
        borderRadius: borderRadius12,
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: borderRadius12,
            color: Colors.black12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: fontBold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
