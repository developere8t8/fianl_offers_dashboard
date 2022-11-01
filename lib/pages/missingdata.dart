import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:fianl_offer_dashboard/models/region.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../constants.dart';
import '../widgets/error.dart';
import '../widgets/text_field.dart';
import 'Auth.dart';
import 'login_page.dart';

class AddMissingData extends StatefulWidget {
  const AddMissingData({super.key});

  @override
  State<AddMissingData> createState() => _AddMissingDataState();
}

class _AddMissingDataState extends State<AddMissingData> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController email = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController regNumber = TextEditingController();
  TextEditingController physicalAddress = TextEditingController();
  TextEditingController region = TextEditingController(text: '--please select--');
  List<GlobalKey<FormState>> keys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  bool isLoading = false;
  XFile? img;
  bool value = false;
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;
  bool lastField = false;
  bool secondField = true;
  List<RegionData> regions = [];
  List<String> regionNames = [];
  String? selectedRegion = '';
  @override
  void initState() {
    email.text = user.email!;
    name.text = user.displayName!;
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: Row(
                    children: const [
                      LoadingIndicator(indicatorType: Indicator.lineScalePulseOut),
                      LoadingIndicator(indicatorType: Indicator.lineScalePulseOut)
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 600,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/login.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(kColorBlack.withOpacity(0.3), BlendMode.darken),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 150),
                          Text(
                            'Complete Profile\nFinal Offer',
                            style: TextStyle(
                              fontSize: 55,
                              fontWeight: FontWeight.w700,
                              color: kColorWhite,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Ut tellus quis in imperdiet pharetra.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: kColorWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 150),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: kUIDark,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Enter details to complete your account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kUILight2,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          height: 682,
                          width: 374,
                          child: Theme(
                            data: ThemeData(canvasColor: kColorWhite),
                            child: Stepper(
                              controlsBuilder: (BuildContext context, ControlsDetails details) {
                                return lastField
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 29,
                                          ),
                                          Container(
                                            width: 374,
                                            height: 52,
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                                  offset: Offset(0.0, 8.0),
                                                  blurRadius: 24,
                                                ),
                                              ],
                                            ),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                createUser();
                                              },
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(104),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all(kPrimary1),
                                                foregroundColor: MaterialStateProperty.all(kColorWhite),
                                                // padding: MaterialStateProperty.all(
                                                //   EdgeInsets.symmetric(vertical: 14),
                                                // ),
                                                textStyle: MaterialStateProperty.all(
                                                  const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              child: const Text('complete account'),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 29,
                                          ),
                                          Container(
                                            width: 374,
                                            height: 52,
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                                  offset: Offset(0.0, 8.0),
                                                  blurRadius: 24,
                                                ),
                                              ],
                                            ),
                                            child: OutlinedButton(
                                              onPressed: details.onStepContinue,
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(104),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all(kPrimary1),
                                                foregroundColor: MaterialStateProperty.all(kColorWhite),
                                                // padding: MaterialStateProperty.all(
                                                //   EdgeInsets.symmetric(vertical: 14),
                                                // ),
                                                textStyle: MaterialStateProperty.all(
                                                  const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Next'),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          // Wrap(
                                          //   children: [
                                          //     const Text(
                                          //       'Already have an account? ',
                                          //       style: TextStyle(
                                          //         fontSize: 13,
                                          //         fontWeight: FontWeight.w600,
                                          //         color: kUIDark,
                                          //       ),
                                          //     ),
                                          //     InkWell(
                                          //       onTap: () {
                                          //         Navigator.push(
                                          //           context,
                                          //           MaterialPageRoute(
                                          //             builder: (context) => const LoginPage(),
                                          //           ),
                                          //         );
                                          //       },
                                          //       child: const Text(
                                          //         'Sign in',
                                          //         style: TextStyle(
                                          //           decoration: TextDecoration.underline,
                                          //           fontSize: 13,
                                          //           fontWeight: FontWeight.w500,
                                          //           color: kPrimary1,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      );
                              },
                              type: stepperType,
                              elevation: 0,
                              physics: const ScrollPhysics(),
                              currentStep: _currentStep,
                              onStepTapped: (step) => tapped(step),
                              onStepContinue: continued,
                              onStepCancel: cancel,
                              steps: <Step>[
                                Step(
                                  title: const Text(''),
                                  content: Form(
                                    key: keys[0],
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Company name *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            hintText: 'First name',
                                            ebColor: kUILight,
                                            controller: name,
                                            validate: true,
                                            errorTxt: 'enter company name',
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Email address *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            controller: email,
                                            validate: true,
                                            errorTxt: 'enter email',
                                            hintText: 'example@gmail.com',
                                            ebColor: kUILight,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Contact number *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            controller: contact,
                                            validate: true,
                                            errorTxt: 'enter contact number',
                                            hintText: 'Enter contact number',
                                            ebColor: kUILight,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Company reg number *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            controller: regNumber,
                                            validate: true,
                                            errorTxt: 'enter reg no',
                                            hintText: 'Enter company reg number',
                                            ebColor: kUILight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
                                ),
                                Step(
                                  title: const Text(''),
                                  content: Form(
                                    key: keys[1],
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Physical address *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            controller: physicalAddress,
                                            validate: true,
                                            errorTxt: 'enter physical address',
                                            hintText: 'Enter physical address',
                                            ebColor: kUILight,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Address *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: TextFieldWidget(
                                            controller: address,
                                            validate: true,
                                            errorTxt: 'enter address',
                                            hintText: 'Enter address',
                                            ebColor: kUILight,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Region *',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: kUIDark,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 370,
                                          height: 52,
                                          child: SizedBox(
                                              width: 221,
                                              height: 43,
                                              child: Container(
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: kFormStockColor,
                                                        style: BorderStyle.solid),
                                                    borderRadius: BorderRadius.circular(5)),
                                                width: 220,
                                                height: 30,
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                      icon: const Icon(Icons.arrow_downward),
                                                      //hint: const Text('  --Please Select--'),
                                                      value: selectedRegion,
                                                      dropdownColor: Colors.white,
                                                      focusColor: Colors.white,
                                                      isDense: true,
                                                      items: regionNames.map((String items) {
                                                        return DropdownMenuItem(
                                                          value: items,
                                                          child: Text(
                                                            items,
                                                            style: const TextStyle(
                                                              color: kPrimary1,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          region.text = value!;
                                                          selectedRegion = value;
                                                        });
                                                      }),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
                                ),
                                Step(
                                  title: const Text(''),
                                  content: Form(
                                      key: keys[2],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Create Password *',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: kUIDark,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 370,
                                            height: 52,
                                            child: TextFieldWidget(
                                              validate: true,
                                              controller: password,
                                              errorTxt: 'enter a password',
                                              hintText: 'Enter Password (minimum 7 characters)',
                                              ebColor: kUILight,
                                              obscure: true,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            'Confirm Password *',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: kUIDark,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 370,
                                            height: 52,
                                            child: TextFieldWidget(
                                              controller: confirmPassword,
                                              validate: true,
                                              errorTxt: 'enter password again',
                                              hintText: 'Confirm Password',
                                              ebColor: kUILight,
                                              obscure: true,
                                            ),
                                          ),
                                        ],
                                      )),
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
                                ),
                                Step(
                                  title: const Text(''),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Upload Picture',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: kUIDark,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Stack(
                                        children: [
                                          DottedBorder(
                                              borderType: BorderType.Circle,
                                              color: kPrimary1,
                                              strokeWidth: 2,
                                              dashPattern: [10, 10],
                                              child: SizedBox(
                                                //height: 184.h,
                                                //width: 184.h,
                                                child: img != null
                                                    ? CircleAvatar(
                                                        backgroundColor: Colors.white,
                                                        radius: 100,
                                                        backgroundImage: NetworkImage(
                                                          img!.path,
                                                        ),
                                                      )
                                                    : const CircleAvatar(
                                                        backgroundColor: Colors.white,
                                                        radius: 100,
                                                        backgroundImage: null,
                                                      ),
                                              ) // child: SizedBox(

                                              ),
                                          Positioned(
                                              left: 0,
                                              right: 140,
                                              top: 180,
                                              bottom: 0,
                                              child: IconButton(
                                                  onPressed: () {
                                                    pickImage();
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.camera,
                                                    color: Colors.blue,
                                                  )))
                                        ],
                                      )
                                    ],
                                  ),
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 3 ? StepState.complete : StepState.disabled,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    if (_currentStep < 3) {
      if (_currentStep == 2 && password.text != confirmPassword.text) {
        showMsg(
            'password and confirm password did not match',
            const Icon(
              Icons.close,
              color: Colors.red,
            ),
            context);
      } else {
        if (keys[_currentStep].currentState!.validate()) {
          setState(() {
            _currentStep += 1;
          });
        }
      }
      if (_currentStep == 3) {
        setState(() {
          lastField = true;
        });
      } else {
        setState(() {
          lastField = false;
        });
      }
    } else {
      null;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  //creating user
  Future createUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (img != null) {
        // UserCredential credential = await FirebaseAuth.instance
        //     .createUserWithEmailAndPassword(email: email.text, password: password.text);
        // //await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
        final newUser = FirebaseAuth.instance.currentUser;
        //uploading image
        if (newUser != null) {
          final firebaseStorage = FirebaseStorage.instance;
          var snapshot = await firebaseStorage.ref().child('/profile_picks/${newUser.uid}').putData(
                await img!.readAsBytes(),
                SettableMetadata(contentType: 'image/jpeg'),
              );
          var imgUrlNew = await snapshot.ref.getDownloadURL();
          final addUser = FirebaseFirestore.instance.collection('compnies').doc(newUser.uid);
          CompanyData company = CompanyData(
              active: false,
              contact: contact.text,
              date: Timestamp.fromDate(DateTime.now()),
              email: email.text,
              id: newUser.uid,
              name: name.text,
              reg: regNumber.text,
              imgUrl: imgUrlNew,
              companyName: name.text,
              address: address.text,
              physicalAddress: physicalAddress.text,
              region: region.text,
              admin: name.text,
              city: '',
              fb: '',
              insta: '',
              vat: '',
              web: '',
              adminStatus: 'Pending');

          await addUser.update(company.toMap());
          setState(() {
            isLoading = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CheckAuth()));
        } else {
          // ignore: use_build_context_synchronously
          showMsg(
              'pick an image to create account',
              const Icon(
                Icons.close,
                color: Colors.red,
              ),
              context);
          //tapped(4);
        }
      } else {
        // ignore: use_build_context_synchronously
        showMsg(
            'pick an image to create account',
            const Icon(
              Icons.close,
              color: Colors.red,
            ),
            context);
        //tapped(4);
      }
    } catch (e) {
      showMsg(
          e.toString(),
          const Icon(
            Icons.close,
            color: Colors.red,
          ),
          context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //pcik image
  Future pickImage() async {
    // ignore: invalid_use_of_visible_for_testing_member
    final imageweb = await ImagePicker.platform.getImage(source: ImageSource.gallery);
    if (imageweb != null) {
      setState(() {
        img = imageweb;
      });
    }
  }

  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snap =
          await FirebaseFirestore.instance.collection('region').where('active', isEqualTo: true).get();
      setState(() {
        regions = snap.docs.map((e) => RegionData.fromMap(e.data() as Map<String, dynamic>)).toList();
        regionNames = regions.map((e) => e.region!).toList();
        selectedRegion = regionNames[0];
      });
    } catch (e) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorDialog(
                  title: 'Error',
                  message: e.toString(),
                  type: 'E',
                  function: () {
                    Navigator.pop(context);
                  },
                  buttontxt: 'Close')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
