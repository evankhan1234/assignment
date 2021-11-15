import 'dart:io';
import 'package:assignment/views/loading_widget.dart';
import 'package:flutter/material.dart';


class NoInternetConScreen extends StatefulWidget {
  const NoInternetConScreen({Key? key}) : super(key: key);

  @override
  _NoInternetConScreenState createState() => _NoInternetConScreenState();
}

class _NoInternetConScreenState extends State<NoInternetConScreen> {
  bool isLoading = false;
  int? radioGroup = 1;

  @override
  void initState() {
    isLoading = false;
    // Future.delayed(Duration.zero, () async {
    //   openConnection();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void openConnection() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'No Internet Connection!',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    setState(() {
                      radioGroup = 1;
                    });
                  },
                  horizontalTitleGap: 0,
                  leading: Radio(
                      value: 1,
                      groupValue: radioGroup,
                      onChanged: (int? val) {
                        setState(() {
                          radioGroup = val;
                        });
                      }),
                  title: const Text(
                    'Turn on Wi-Fi',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      radioGroup = 2;
                    });
                  },
                  horizontalTitleGap: 0,
                  leading: Radio(
                      value: 2,
                      activeColor: Colors.deepOrangeAccent,
                      groupValue: radioGroup,
                      onChanged: (int? val) {
                        setState(() {
                          radioGroup = val;
                        });
                      }),
                  title: const Text(
                    'Turn on mobile data',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  )),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverToBoxAdapter(
                child: Image(
                  // width: double.infinity,
                  height:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.5
                      : MediaQuery.of(context).size.height * 0.8,
                  image: const AssetImage(
                    'images/no_internet_con.png',
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Ooops!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'No internet connection found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Please check your network settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final result =
                        await InternetAddress.lookup('example.com');
                        if (result.isNotEmpty &&
                            result[0].rawAddress.isNotEmpty) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context)
                              .pushReplacementNamed('/login');
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please turn on mobile data or wifi')));
                        }
                      } on SocketException catch (_) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please turn on mobile data or wifi')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xfff68721), shape: const StadiumBorder()),
                    child: isLoading
                        ? const LoadingWidget(color: Colors.white,)
                        : const Text(
                      'RETRY',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}