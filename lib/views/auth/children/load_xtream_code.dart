// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/labeled_textfield.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/logo.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';
import 'package:seizhiptv/models/source.dart';

class LoadXtreamCodePage extends StatefulWidget {
  const LoadXtreamCodePage({super.key});

  @override
  State<LoadXtreamCodePage> createState() => _LoadXtreamCodePageState();
}

class _LoadXtreamCodePageState extends State<LoadXtreamCodePage> {
  final GlobalKey<FormState> kForm = GlobalKey<FormState>();
  final M3uFirestoreServices _service = M3uFirestoreServices();
  late final TextEditingController _sourceName, _username, _password, _url;
  var date = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    _sourceName = TextEditingController();
    _username = TextEditingController();
    _password = TextEditingController();
    _url = TextEditingController();
    date = DateTime(date.year, date.month + 1, date.day);
    super.initState();
  }

  @override
  void dispose() {
    _sourceName.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade800,
            body: Container(
              decoration: BoxDecoration(gradient: ColorPalette().gradient),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: "auth-logo",
                    child: LogoSVG(bottomText: "Load_your_source".tr()),
                  ),
                  Form(
                    key: kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _sourceName,
                          label: "Source_Name".tr(),
                          hinttext: "Type your Source Name",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          controller: _username,
                          label: "Username".tr(),
                          hinttext: "Type your username",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          isPassword: true,
                          controller: _password,
                          label: "Password".tr(),
                          hinttext: "Type your password",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          controller: _url,
                          label: "URL",
                          hinttext: "http://url_here.com:port",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    onPressed: () async {
                      // FocusScope.of(context).unfocus();
                      print(_url.text);
                      print(_username.text);
                      print(_password.text);
                      print("SOURCE");
                      print(
                        "${_url.text}/get.php?username=${_username.text}&password=${_password.text}&type=m3u_plus&output=mpegts",
                      );

                      final String source =
                          "${_url.text}/get.php?username=${_username.text}&password=${_password.text}&type=m3u_plus";
                      try {
                        await _service.firestore
                            .collection("user-source")
                            .doc(refId)
                            .set({
                              "sources": FieldValue.arrayUnion([
                                M3uSource(
                                  source: source,
                                  isFile: false,
                                  name: _sourceName.text,
                                ).toJson(),
                              ]),
                            }, SetOptions(merge: true));
                        Navigator.of(context).pop();
                        _sourceName.clear();
                        _url.clear();
                        _username.clear();
                        _password.clear();
                      } catch (e, s) {
                        print("errorrrr $e");
                        print("errorrrr $s");
                      }
                    },
                    color: ColorPalette().orange,
                    height: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 5),
                        Text("Add_Source".tr()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    height: 50,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        "Cancel".tr(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            const Positioned.fill(child: SeizhTvLoader(opacity: .7)),
          },
        ],
      ),
    );
  }
}
