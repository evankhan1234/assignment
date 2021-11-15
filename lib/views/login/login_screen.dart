import 'dart:io';
import 'dart:math';
import 'package:assignment/utils/database_service.dart';
import 'package:assignment/utils/shared_preferences.dart';
import 'package:assignment/views/otp/otp_screen.dart';
import 'package:assignment/views/signup/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  var userController = TextEditingController();
  var passwordController = TextEditingController();
  String? email;
  String? password;
  bool canLoading = false;
  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );


  final GlobalKey<FormState> _loginPhoneFormKey = GlobalKey<FormState>();
  var phoneController = TextEditingController();
  late String phone;

  String? validationEmail(String? value) {
    if (value!.isEmpty) {
      return 'Enter an email!';
    } else if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email!';
    } else {
      return null;
    }
  }
  String? validationMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Mobile No!';
    } else if (value.length < 10) {
      return 'Enter Valid Mobile No!';
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

  void login() async{
    setState(() {
      canLoading = true;
    });
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!
      );
      String uid = userCredential.user!.uid;
      localStorage.setString(MySharedPreference.uid, uid);
      var token = userCredential.user!.getIdToken();
      localStorage.setString(MySharedPreference.token, token.toString());
      setState(() {
        canLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/HomeScreen');
    } on FirebaseAuthException catch (e) {
      setState(() {
        canLoading = false;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password provided for that user.')));
      }
    }
  }

  void LoginWithPhone2()async {
    var random = Random();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'example${random.nextInt(1000).toString()}@gmail.com',
          password: '1234567'
      );
      String uid = userCredential.user!.uid;
      localStorage.setString(MySharedPreference.uid, uid);
      await DatabaseService(uid).updateUserData('demo', phone);
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The account already exists for that Phone Number.')));
      }
    } catch (e) {
      setState(() {
        canLoading = false;
      });
      print(e);
    }
  }

  //................. rejected ...................
  void loginWithPhone() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: '+$phone',
        timeout: const Duration(minutes: 2),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('................verificationCompleted..................');
          // ANDROID ONLY!
          // Sign the user in (or link) with the auto-generated credential
          await auth.signInWithCredential(credential).then((value){
            if (value.user != null) {
              var token = credential.token;
              localStorage.setString(MySharedPreference.token, token.toString());
              Navigator.pushReplacementNamed(context, '/HomeScreen');
            }  else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Something went wrong! Try again!'),backgroundColor: const Color(0xffF87537).withOpacity(0.9),));
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            canLoading = false;
          });
          print('................verificationFailed..................');
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Invalid Phone Number!'),backgroundColor: const Color(0xffF87537).withOpacity(0.9),));
          }
        },
        codeSent: (String verificationId, int? resendToken) async{
          print('................codeSent...............');
          // Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(mobileNo: phone,)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            canLoading = false;
          });
          print('................codeAutoRetrievalTimeout..................');

        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: const Text('No user found for that email.'),backgroundColor: const Color(0xffF87537).withOpacity(0.9),));

      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: const Text('Wrong password provided for that user.'),backgroundColor: const Color(0xffF87537).withOpacity(0.9),));
      }
    }
  }

  /// ...........................
  int radioGp = 1;
  String? hintText = 'Email';

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
              left: -150,
              bottom: 0,
              child: SvgPicture.asset('images/login_svg1.svg',height: 400,width: 300,),
            ),
            Align(
              alignment: Alignment.center,
              child: CustomScrollView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: SvgPicture.asset(
                  //       'images/pentagorn.svg',
                  //       semanticsLabel: 'A red up arrow'
                  //   )
                  // ),
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
                      child: const Text('Login',style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: const Text('Please sign in to continue',style: TextStyle(color: Colors.black54,fontSize: 14,fontWeight: FontWeight.normal),),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: const Text('Sign in with?',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        // color: Colors.white.withOpacity(0.8)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio(
                              value: 1,
                              groupValue: radioGp,
                              onChanged: (int? value){
                                setState(() {
                                  radioGp = value!;
                                });
                              }
                          ),
                          const SizedBox(
                            width: 0,
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                radioGp = 1;
                              });
                            },
                            child: const Text('Email',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),),
                          ),
                          Radio(
                              value: 2,
                              groupValue: radioGp,
                              onChanged: (int? value){
                                setState(() {
                                  radioGp = value!;
                                });
                              }
                          ),
                          const SizedBox(
                            width: 0,
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                radioGp = 2;
                              });
                            },
                            child: const Text('Phone',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),),
                          ),
                        ],
                      ),
                    )
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 16,
                    ),
                  ),
                  SliverLayoutBuilder(
                    builder: (BuildContext context, SliverConstraints constraints){
                      if (radioGp == 1) {
                        return SliverToBoxAdapter(
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
                                          controller: userController,
                                          validator: radioGp == 1 ? validationEmail : validationMobile,
                                          cursorColor: Colors.black87,
                                          textInputAction: TextInputAction.next,
                                          onSaved: (String? val) {
                                            email = val;
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
                                            hintText: 'Email/Phone',
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
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: const Color(0xffF87537),
                                            shape: const StadiumBorder()
                                        ),
                                        onPressed: () async {
                                          if (_loginFormKey.currentState!.validate()) {
                                            _loginFormKey.currentState!.save();
                                            try {
                                              final result = await InternetAddress.lookup('example.com');
                                              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                if (radioGp == 1) {
                                                  login();
                                                }  else {
                                                  loginWithPhone();
                                                }
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
                                          ) : const Text('LOGIN',style: TextStyle(color: Colors.white),),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }  else {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                            child: Form(
                              key: _loginPhoneFormKey,
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: double.infinity,
                                      child: Material(
                                        elevation: 6,
                                        shadowColor: Colors.grey.withOpacity(0.4),
                                        clipBehavior: Clip.antiAlias,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        child: TextFormField(
                                          maxLengthEnforcement: MaxLengthEnforcement.enforced, style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                          controller: phoneController,
                                          validator: validationMobile,
                                          cursorColor: Colors.black87,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          textInputAction: TextInputAction.done,
                                          onSaved: (String? val) {
                                            phone = val!;
                                          },
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
                                            hintText: 'Phone',
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
                                    height: 16,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: const Color(0xffF87537),
                                            shape: const StadiumBorder()
                                        ),
                                        onPressed: () async {
                                          if (_loginPhoneFormKey.currentState!.validate()) {
                                            _loginPhoneFormKey.currentState!.save();
                                            try {
                                              final result = await InternetAddress.lookup('example.com');
                                              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                setState(() {
                                                  canLoading = true;
                                                });
                                                LoginWithPhone2();
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
                                          ) : const Text('Continue',style: TextStyle(color: Colors.white),),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 30,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20,horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?',style: TextStyle(color: Colors.black87,fontSize: 16),),
                          const SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                            },
                            child: const Text('Signup',style: TextStyle(color: Color(0xffF87537),fontSize: 16,fontWeight: FontWeight.w600),),
                          )
                        ],
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

