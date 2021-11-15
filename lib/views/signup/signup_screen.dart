import 'dart:io';

import 'package:assignment/utils/database_service.dart';
import 'package:assignment/utils/shared_preferences.dart';
import 'package:assignment/views/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  String? email;
  String? password;
  String? confirmPassword;
  String? mobile;
  String? name;
  bool canLoading = false;
  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  String? validationUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Name!';
    } else {
      return null;
    }
  }
  String? validationMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Mobile!';
    } else if (value.length < 10) {
      return 'Enter Valid Number';
    } else {
      return null;
    }
  }
  String? validationEmail(String? value) {
    if (value!.isEmpty) {
      return 'Enter an email!';
    } else if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email!';
    } else {
      return null;
    }
  }
  String? validationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Password!';
    } else if (value.length < 5) {
      return 'Enter minimum 5 digit';
    } else {
      return null;
    }
  }
  String? validationConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Confirm Password!';
    } else if (value.compareTo(passwordController.text.toString()) == 0) {
      return null;
    } else {
      return 'Doesn\'t match with password';
    }
  }
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  void initState() {
    canLoading = false;
    super.initState();
  }

  void signup() async{
    setState(() {
      canLoading = true;
    });
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email!,
          password: password!
      );
      String uid = userCredential.user!.uid;
      localStorage.setString(MySharedPreference.uid, uid);
      await DatabaseService(uid).updateUserData(name!, mobile!);
      var token = userCredential.user!.getIdToken();
      localStorage.setString(MySharedPreference.token, token.toString());
      setState(() {
        canLoading = false;
      });
      Navigator.pushNamedAndRemoveUntil(context, '/HomeScreen',(Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        canLoading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        canLoading = false;
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The account already exists for that email.')));
      }
    } catch (e) {
      setState(() {
        canLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Positioned(
            //   // alignment: Alignment.topRight,
            //   top: 0,
            //   right: -50,
            //   child: Transform.rotate(
            //     angle: -45,
            //     child: Container(
            //       height: 100,
            //       width: 200,
            //       decoration: BoxDecoration(
            //           color: Colors.deepOrangeAccent.shade400.withOpacity(0.7),
            //           borderRadius: BorderRadius.circular(20)
            //       ),
            //     ),
            //   ),
            // ),
            // Positioned(
            //   // alignment: Alignment.topRight,
            //   top: 30,
            //   right: -50,
            //   child: Transform.rotate(
            //     angle: -45,
            //     child: Container(
            //       height: 100,
            //       width: 200,
            //       decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.4),
            //           borderRadius: BorderRadius.circular(20)
            //       ),
            //     ),
            //   ),
            // ),
            const Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                backgroundColor: Color(0xffF87537),
                radius: 80,
              ),
            ),
            Positioned(
              top: -70,
              right: -50,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 80,
              ),
            ),
            Positioned(
              top: 0,
              left: -200,
              bottom: 0,
              child: SvgPicture.asset('images/login_svg1.svg',height: 600,width: 300,),
            ),
            Align(
              alignment: Alignment.center,
              child: CustomScrollView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                slivers: [
                  // const SliverToBoxAdapter(
                  //     child: Image(image: AssetImage('images/pentagon.png'),height: 150,width: 150,)
                  // ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: const Text('Create Account',style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: const Text('Please sign up to continue',style: TextStyle(color: Colors.black54,fontSize: 14,fontWeight: FontWeight.normal),),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          children: [
                            SizedBox(
                                width: double.infinity,
                                child: Material(
                                  elevation: 6,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    controller: nameController,
                                    validator: validationUserName,
                                    cursorColor: Colors.black87,
                                    textInputAction: TextInputAction.next,
                                    onSaved: (String? val) {
                                      name = val;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      alignLabelWithHint: true,
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.black54,
                                      ),
                                      filled: true,
                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                      fillColor: Colors.white,
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      hintText: 'Name',
                                      hintStyle:
                                      TextStyle(color: Colors.black54, fontSize: 18),
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Material(
                                  elevation: 6,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    controller: emailController,
                                    validator: validationEmail,
                                    cursorColor: Colors.black87,
                                    textInputAction: TextInputAction.next,
                                    onSaved: (String? val) {
                                      email = val;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      alignLabelWithHint: true,
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.black54,
                                      ),
                                      filled: true,
                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                      fillColor: Colors.white,
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      hintText: 'Email',
                                      hintStyle:
                                      TextStyle(color: Colors.black54, fontSize: 18),
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Material(
                                  elevation: 6,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    controller: mobileController,
                                    validator: validationMobile,
                                    cursorColor: Colors.black87,
                                    textInputAction: TextInputAction.next,
                                    onSaved: (String? val) {
                                      mobile = val;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      alignLabelWithHint: true,
                                      prefixIcon: Icon(
                                        Icons.phone,
                                        color: Colors.black54,
                                      ),
                                      filled: true,
                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                      fillColor: Colors.white,
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      hintText: 'Mobile',
                                      hintStyle:
                                      TextStyle(color: Colors.black54, fontSize: 18),
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Material(
                                  elevation: 6,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    controller: passwordController,
                                    validator: validationPassword,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _obscureText,
                                    maxLines: 1,
                                    cursorColor: Colors.black87,
                                    onSaved: (String? val) {
                                      password = val;
                                    },
                                    decoration: InputDecoration(
                                      // icon: Icon(Icons.vpn_key_outlined),
                                      prefixIcon: const Icon(
                                        Icons.vpn_key_outlined,
                                        color: Colors.black54,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: _obscureText
                                            ? const Icon(
                                          Icons.visibility_off,
                                          color: Colors.black54,
                                        )
                                            : const Icon(
                                          Icons.visibility,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: 'Password',
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Material(
                                  elevation: 6,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    controller: confirmPasswordController,
                                    validator: validationConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _obscureText,
                                    maxLines: 1,
                                    cursorColor: Colors.black87,
                                    onSaved: (String? val) {
                                      confirmPassword = val;
                                    },
                                    decoration: InputDecoration(
                                      // icon: Icon(Icons.vpn_key_outlined),
                                      prefixIcon: const Icon(
                                        Icons.vpn_key_outlined,
                                        color: Colors.black54,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: _obscureText
                                            ? const Icon(
                                          Icons.visibility_off,
                                          color: Colors.black54,
                                        )
                                            : const Icon(
                                          Icons.visibility,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: 'Confirm Password',
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: const Color(0xffF87537),
                                      shape: const StadiumBorder()
                                  ),
                                  onPressed: () async{
                                    if (_loginFormKey.currentState!.validate()) {
                                      _loginFormKey.currentState!.save();
                                      try {
                                        final result = await InternetAddress.lookup('example.com');
                                        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                          signup();
                                        }
                                      } on SocketException catch (_) {
                                        print('not connected');
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Internet Connection! Try Again')));
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 16),
                                    child: canLoading ? const SizedBox(
                                      height: 20,width: 20,
                                      child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,),
                                    ) : const Text('SIGN UP',style: TextStyle(color: Colors.white),),
                                  )
                              ),
                            ),
                            
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20,horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already you have an account?',style: TextStyle(color: Colors.black87,fontSize: 16),),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Login',style: TextStyle(color: Colors.deepOrangeAccent,fontSize: 16,fontWeight: FontWeight.w600),),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

