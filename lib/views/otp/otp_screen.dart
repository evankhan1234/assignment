import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key,this.mobileNo}) : super(key: key);
  final String? mobileNo;

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _optKey = GlobalKey<FormState>();
  var firstController = TextEditingController();
  var secondController = TextEditingController();
  var thirdController = TextEditingController();
  var forthController = TextEditingController();
  var fifthController = TextEditingController();

  String? first,second,third,forth,fifth;
  bool canLoading = false;

  String? firstValidation(String? value){
    if (value == null || value.isEmpty) {
      // Common.toastMsg('Enter OTP');
      return '';
    } else {
      return null;
    }
  }
  String? secondValidation(String? value){
    if (value == null || value.isEmpty) {
      // Common.toastMsg('Enter OTP');
      return '';
    } else {
      return null;
    }
  }
  String? thirdValidation(String? value){
    if (value == null || value.isEmpty) {
      // Common.toastMsg('Enter OTP');
      return '';
    } else {
      return null;
    }
  }
  String? forthValidation(String? value){
    if (value == null || value.isEmpty) {
      // Common.toastMsg('Enter OTP');
      return '';
    } else {
      return null;
    }
  }
  String? fifthValidation(String? value){
    if (value == null || value.isEmpty) {
      // Common.toastMsg('Enter OTP');
      return '';
    } else {
      return null;
    }
  }

  FocusNode? firstNode;
  FocusNode? secondNode;
  FocusNode? thirdNode;
  FocusNode? forthNode;
  FocusNode? fifthNode;

  @override
  void initState() {
    canLoading = false;
    firstNode = FocusNode();
    secondNode = FocusNode();
    thirdNode = FocusNode();
    forthNode = FocusNode();
    fifthNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    firstNode!.dispose();
    secondNode!.dispose();
    thirdNode!.dispose();
    forthNode!.dispose();
    fifthNode!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: SvgPicture.asset('images/egg.svg',height: 150,width: 100,),
              )
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 80,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                child: Text('+${widget.mobileNo}',textAlign: TextAlign.center,style: const TextStyle(color: Colors.black87,fontSize: 16,),),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 8,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                child: Text('You\'ll received a 6 digit code \nto verify mobile no',textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontSize: 16,),),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 16,
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _optKey,
                autovalidateMode: AutovalidateMode.always,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFC7C7C7))
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 1,
                        maxLines: 1,
                        validator: firstValidation,
                        focusNode: firstNode,
                        autofocus: true,
                        onChanged: (value){
                          if (value.isNotEmpty) {
                            FocusScope.of(context).requestFocus(secondNode);
                          }
                        },
                        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onSaved: (value){
                          first = value;
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFC7C7C7))
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 1,
                        maxLines: 1,
                        focusNode: secondNode,
                        validator: secondValidation,
                        onChanged: (value){
                          if (value.isNotEmpty) {
                            FocusScope.of(context).requestFocus(thirdNode);
                          }
                        },
                        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onSaved: (value){
                          second = value;
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFC7C7C7))
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 1,
                        maxLines: 1,
                        focusNode: thirdNode,
                        validator: thirdValidation,
                        onChanged: (value){
                          if (value.isNotEmpty) {
                            FocusScope.of(context).requestFocus(forthNode);
                          }
                        },
                        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onSaved: (value){
                          third = value;
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFC7C7C7))
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 1,
                        maxLines: 1,
                        focusNode: forthNode,
                        validator: forthValidation,
                        onChanged: (value){
                          if (value.isNotEmpty) {
                            FocusScope.of(context).requestFocus(fifthNode);
                          }
                        },
                        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onSaved: (value){
                          forth = value;
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xFFC7C7C7))
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.done,
                        maxLength: 1,
                        maxLines: 1,
                        focusNode: fifthNode,
                        validator: fifthValidation,
                        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        onSaved: (value){
                          fifth = value;
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            // SliverToBoxAdapter(
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: TextButton(
            //       onPressed: (){
            //         resendOtp();
            //       },
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text('Code Resend',style: TextStyle(color: AppsColors.buttonColor,fontSize: 14,fontWeight: FontWeight.w600),),
            //           SizedBox(
            //             width: 10,
            //           ),
            //           Icon(Icons.replay,color: AppsColors.buttonColor,size: 16,),
            //           SizedBox(
            //             width: 10,
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 16,
              ),
            ),

            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xffF87537),
                          shape: const StadiumBorder()
                      ),
                      onPressed: () async{
                        if (_optKey.currentState!.validate()) {
                          _optKey.currentState!.save();
                          try {
                            final result = await InternetAddress.lookup('example.com');
                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                              setState(() {
                                canLoading = true;
                              });
                            }
                          } on SocketException catch (_) {
                            print('not connected');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Internet Connection! Try Again')));
                          }
                          // verifyOtp();
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter OTP')));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 16),
                        child: canLoading ? const SizedBox(
                          height: 20,width: 20,
                          child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,),
                        ) : const Text('SUBMIT',style: TextStyle(color: Colors.white),),
                      )
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
              ),
            ),
          ],
        ),
      )
    );
  }
}
