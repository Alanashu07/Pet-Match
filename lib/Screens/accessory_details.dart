import 'package:flutter/material.dart';
import 'package:pet_match/Screens/MainScreens/ProfileWidgets/custom_back_button.dart';
import 'package:provider/provider.dart';
import '../Constants/global_variables.dart';
import '../Models/accessory_model.dart';
import '../Styles/app_style.dart';
import '../Widgets/accessory_images_card.dart';
import '../Widgets/accessory_name_header.dart';

class AccessoryDetails extends StatefulWidget {
  final Accessory accessory;
  const AccessoryDetails({super.key, required this.accessory});

  @override
  State<AccessoryDetails> createState() => _AccessoryDetailsState();
}

class _AccessoryDetailsState extends State<AccessoryDetails> {

  bool isUploading = false;
  bool bought = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final myAccessory = context.watch<GlobalVariables>().allAccessories.firstWhere((element) => element.id == widget.accessory.id);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  SizedBox(height: mq.height*.05,),
                  AccessoryImagesCard(accessory: myAccessory,),
                  SizedBox(height: mq.height*.03,),
                  AccessoryNameHeader(accessory: myAccessory),
                  Text('Available Quantity: ${myAccessory.quantity.round()}', style: TextStyle(color: myAccessory.quantity > 10 ? AppStyle.mainColor : Colors.red, fontSize: 18),),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        myAccessory.description,
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          bought = true;
                        });
                      },
                      child: AnimatedContainer(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: bought ? Colors.green[900] : AppStyle.mainColor),
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    bought ? 'Congratulations...!' : 'Buy Now',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                )),
                            AnimatedRotation(
                              turns: bought ? 0 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.pets,
                                  color: bought
                                      ? Colors.green[900]
                                      : AppStyle.mainColor,
                                  size: 30,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: mq.height*.05, horizontal: mq.width*.03), child: CustomBackButton(onTap: (){
            Navigator.pop(context);
          }),)
        ],
      ),
    );
  }
}
