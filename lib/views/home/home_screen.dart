import 'dart:convert';

import 'package:assignment/models/token_model.dart';
import 'package:assignment/utils/database_service.dart';
import 'package:assignment/utils/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _notificationKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var bodyController = TextEditingController();
  String? title;
  String? body;
  bool canLoading = false;

  String? validationUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Notification Title!';
    } else {
      return null;
    }
  }
  String? validationBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Notification body!';
    } else {
      return null;
    }
  }

  //////////////////////////////////////////
  final GlobalKey<FormState> _updateInfoKey = GlobalKey<FormState>();
  var nameControllerD = TextEditingController();
  var mobileController = TextEditingController();
  String? nameD;
  String? mobileD;
  String? validationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Notification Title!';
    } else {
      return null;
    }
  }
  String? validationMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty Mobile No!';
    } else if (value.length < 10) {
      return 'Enter Valid Number!';
    }
    else {
      return null;
    }
  }

  CollectionReference users = FirebaseFirestore.instance.collection('brew');
  SharedPreferences? localStorage;
  String? uid;
  String? token;

  @override
  void initState() {
    getData();
    saveTokenData();
    canLoading = false;
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_){
    //   getData();
    //   saveTokenData();
    // });
  }

  void saveTokenData()async {
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    print('1111111111111111111');
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(updateTokenToDatabase);
  }
  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await userCollection
        .doc(userId)
        .set({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }
  Future<void> updateTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await userCollection
        .doc(userId)
        .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  void sendPushNotification() async {
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot? querySnapshot) {
      final allData = querySnapshot!.docs.map((doc) => doc.data()).toList();
          for(var i = 0; i < allData.length; i++){
            var jsonEncodedData = json.encode(allData[i]);
            Map<String, dynamic> parsed = json.decode(jsonEncodedData);
            TokenModel tokenModel = TokenModel.fromJson(parsed);
            for(var token in tokenModel.tokens){
              print('Token : $token');
              pushNotification(token);
            }
          }
      titleController.text = '';
      bodyController.text = '';
    });
  }
  void getData() async {
    //cCplj2YkQPuuhod6GtDHfl:APA91bGoiR0G3YA7Kb6cRLjmR4W0DQXB2WmTXKAUGUGX0RSHlainDG22epmN2rZvH5K0CRLZ41Tb3Rit0cHWvhp-y0rlSLYBvMRu_ki2sfhL13s8NQUQm2QE_vgdkTQAfMN976WODMa1;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) {
      assert(token != null);
      this.token = token;
      print("teken is: " + token!);
    });

    localStorage = await SharedPreferences.getInstance();
    uid = localStorage!.getString(MySharedPreference.uid);
    token = localStorage!.getString(MySharedPreference.token);
    setState(() {

    });
  }
  Future<bool> _onBackPressed(BuildContext context) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to close the app?',style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500),),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
        ],
      ),
    )) ??
        false;
  }
  void pushNotification(String? token) async {
    Client client = Client();
    var request = {};
    var notification = {};
    notification["title"] = title;
    notification["body"] = body;

    request["to"] = '$token';
    request["click_action"] = 'FLUTTER_NOTIFICATION_CLICK';
    request["topics"] = 'all';
    request["priority"] = 'high';
    request["sound"] = '';
    request["notification"] = notification;
    var jsonRequest = json.encode(request);
    const key = "key=AAAAWOLCiSY:APA91bFu4-CQaDP7VK98WdZ-J7DPeD8U9_2x2oLRNUk63B4kVETcyEXOEuJC5JGtyKsg0jb9FC4HTma73FjpV2ItvFGo3l7opFP9csT45Ii6M7GfnSgE1Y7Sz7nqhBOmTcBSIlBM-kJc";
    Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      try{
        var response = await client.post(url,body: jsonRequest,headers: {
          'Authorization': key,
          'Content-type': 'application/json',
          'Charset': 'utf-8',
          'Accept': 'application/json',
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = await json.decode(response.body);
          if (response.body.isNotEmpty) {
            print('successfully pushed notification');
          }
        }else {
          throw Exception('Failed to load post');
        }
      }on Exception catch(e){
        print(e);
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xffF87537),
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Color(0xffF87537),statusBarIconBrightness: Brightness.light),
        actions: [
          IconButton(
              onPressed: ()async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences localStorage = await SharedPreferences.getInstance();
                localStorage.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverToBoxAdapter(
                  child: Material(
                    color: const Color(0xFFFFFFFF),
                    shadowColor: Colors.grey.withOpacity(0.4),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(0),
                    child: Column(
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Color(0xfff4f4f4),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.deepOrangeAccent,
                                backgroundImage: AssetImage('images/pentagon.png'),
                                child: Icon(Icons.person,color: Colors.white,size: 50,),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FutureBuilder<DocumentSnapshot>(
                                    future: users.doc(uid).get(),
                                    builder:
                                        (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text("Something went wrong");
                                      }
                                      if (snapshot.hasData && !snapshot.data!.exists) {
                                        return const Text("Personal Info Not Found!");
                                      }
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                        nameControllerD.text = data['name'];
                                        mobileController.text = data['phone'];
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("${data['name']}",textAlign: TextAlign.center,style: const TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w500),),
                                            Text("${data['phone']}",textAlign: TextAlign.center,style: const TextStyle(color: Colors.black54,fontSize: 16,fontWeight: FontWeight.w400),),
                                          ],
                                        );
                                      }
                                      return const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.deepOrangeAccent,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: (){
                                  showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      enableDrag: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16))),
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      context: context,
                                      builder: (context){
                                        return DraggableScrollableSheet(
                                            expand: false,
                                            builder: (context, scrollController){
                                              return CustomScrollView(
                                                controller: scrollController,
                                                scrollDirection: Axis.vertical,
                                                slivers: [
                                                  SliverToBoxAdapter(
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                      child: Form(
                                                        key: _updateInfoKey,
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: double.infinity,
                                                              child: Text('Update Personal Information',textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.w600),),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: double.infinity,
                                                              child: Text('Name',textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
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
                                                                    controller: nameControllerD,
                                                                    validator: validationName,
                                                                    cursorColor: Colors.black87,
                                                                    textInputAction: TextInputAction.next,
                                                                    onSaved: (String? val) {
                                                                      nameD = val;
                                                                    },
                                                                    keyboardType: TextInputType.text,
                                                                    decoration: const InputDecoration(
                                                                      alignLabelWithHint: true,
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
                                                            const SizedBox(
                                                              width: double.infinity,
                                                              child: Text('Mobile',textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
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
                                                                    controller: mobileController,
                                                                    validator: validationMobile,
                                                                    textInputAction: TextInputAction.done,
                                                                    keyboardType: TextInputType.number,
                                                                    maxLines: 1,
                                                                    cursorColor: Colors.black87,
                                                                    onSaved: (String? val) {
                                                                      mobileD = val;
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                      // icon: Icon(Icons.vpn_key_outlined),
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          horizontal: 20, vertical: 16),
                                                                      // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                                                      fillColor: Colors.white,
                                                                      filled: true,
                                                                      hintText: 'Mobile No',
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
                                                                    if (_updateInfoKey.currentState!.validate()) {
                                                                      _updateInfoKey.currentState!.save();
                                                                      await DatabaseService(uid!).updateUserData(nameD!, mobileD!);
                                                                      Navigator.pop(context);
                                                                      setState(() {

                                                                      });
                                                                    }
                                                                  },
                                                                  child: const Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 30,vertical: 16),
                                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                                  )
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            }
                                        );
                                      }
                                  );
                                },
                                icon: const Icon(Icons.edit,color: Colors.deepOrangeAccent,),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16,
                  ),
                ),
                SliverToBoxAdapter(
                    child: Material(
                      elevation: 0,
                      shadowColor: Colors.grey.withOpacity(0.4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                        decoration: const BoxDecoration(
                            color: Colors.white
                        ),
                        child: Form(
                          key: _notificationKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                width: double.infinity,
                                child: Text('Push Notification',textAlign: TextAlign.start,style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.w600),),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                width: double.infinity,
                                child: Text('Notification Title',textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                              ),
                              const SizedBox(
                                height: 4,
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
                                      controller: titleController,
                                      validator: validationUserName,
                                      cursorColor: Colors.black87,
                                      textInputAction: TextInputAction.next,
                                      onSaved: (String? val) {
                                        title = val;
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                        filled: true,
                                        // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                        fillColor: Colors.white,
                                        contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        hintText: 'Notification Title',
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
                              const SizedBox(
                                width: double.infinity,
                                child: Text('Notification Body',textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                              ),
                              const SizedBox(
                                height: 4,
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
                                      controller: bodyController,
                                      validator: validationBody,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.text,
                                      maxLines: 1,
                                      cursorColor: Colors.black87,
                                      onSaved: (String? val) {
                                        body = val;
                                      },
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.vpn_key_outlined),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 16),
                                        // fillColor: const Color(0xFFD1D2D3).withOpacity(0.4),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Notification Body',
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
                                        primary: Colors.deepOrangeAccent,
                                        shape: const StadiumBorder()
                                    ),
                                    onPressed: () {
                                      if (_notificationKey.currentState!.validate()) {
                                        _notificationKey.currentState!.save();
                                        sendPushNotification();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending push notification')));
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 16),
                                      child: Text('SEND',style: TextStyle(color: Colors.white),),
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
