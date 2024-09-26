import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Constants/alert_option.dart';
import '../Services/firebase_services.dart';
import '../Styles/app_style.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/login_button.dart';
import '../splash_screen.dart';
import 'login_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isSecurePassword = true;
  bool imageAdded = false;
  bool isLogging = false;
  XFile? image;
  String? imageUrl;
  bool isSecureConfirmPassword = true;
  final formKey = GlobalKey<FormState>();

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  Future googleSignIn() async {
    try {
      final google = GoogleSignIn();
      final user = await google.signIn();
      if (user == null) return;
      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
          idToken: auth.idToken, accessToken: auth.accessToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (await FirebaseServices.userExists()) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SplashScreen()));
        FirebaseServices.updateActiveStatus(true);
      } else {
        await FirebaseServices.createUser().then(
          (value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SplashScreen()));
            FirebaseServices.updateActiveStatus(true);
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    imageAdded = image != null;
    final mq = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
            body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: mq.height * .05),
                  child: const Text(
                    "Welcome User",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text("Enter details to create your account",
                    style: TextStyle(color: Colors.black54, fontSize: 18)),
                imageAdded
                    ? Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedImage = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                image = pickedImage;
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: mq.width * .2,
                            backgroundImage: FileImage(File(image!.path)),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedImage = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                image = pickedImage;
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: mq.width * .2,
                            backgroundImage: const AssetImage(
                                'images/dog-in-front-of-a-man.png'),
                          ),
                        ),
                      ),
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          textCapitalization: TextCapitalization.words,
                          controller: nameController,
                          hintText: 'Name',
                          suffixIcon: Icon(
                            CupertinoIcons.person,
                            color: AppStyle.accentColor,
                          ),
                          type: 'Name',
                        ),
                        CustomTextField(
                          textInputType: TextInputType.emailAddress,
                          controller: emailController,
                          hintText: 'Email Id',
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            color: AppStyle.accentColor,
                          ),
                          type: 'Email',
                        ),
                        CustomTextField(
                          textInputType: const TextInputType.numberWithOptions(
                              signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                          ],
                          controller: mobileController,
                          hintText: 'Contact Number',
                          suffixIcon: Icon(
                            Icons.phone,
                            color: AppStyle.accentColor,
                          ),
                          type: 'Mobile',
                        ),
                        CustomTextField(
                          controller: passwordController,
                          hideText: isSecurePassword,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isSecurePassword = !isSecurePassword;
                                });
                              },
                              icon: Icon(
                                isSecurePassword
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: AppStyle.accentColor,
                              )),
                          type: 'Password',
                        ),
                        CustomTextField(
                          controller: confirmPasswordController,
                          hideText: isSecureConfirmPassword,
                          hintText: 'Confirm Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isSecureConfirmPassword =
                                      !isSecureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                isSecureConfirmPassword
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: AppStyle.accentColor,
                              )),
                          type: 'Confirm Password',
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoginButton(
                    onTap: () async {
                      if (formKey.currentState!.validate() &&
                          passwordController.text ==
                              confirmPasswordController.text &&
                          imageAdded) {
                        if (isValidEmail(emailController.text)) {
                          try {
                            setState(() {
                              isLogging = true;
                            });
                            await FirebaseServices.auth
                                .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text);
                            final timeStamp =
                                DateTime.now().millisecondsSinceEpoch;
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref = storage.ref().child(
                                'users/${FirebaseServices.auth.currentUser!.uid}/$timeStamp');
                            await ref.putFile(File(image!.path));
                            imageUrl = await ref.getDownloadURL();
                            FirebaseServices.userWithEmail(
                                name: nameController.text.trim(),
                                password: passwordController.text,
                                phoneNumber: mobileController.text.trim(),
                                email: emailController.text.trim(),
                                image: imageUrl!);
                            setState(() {
                              isLogging = false;
                            });
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child: const SplashScreen(),
                                    type: PageTransitionType.rightToLeftJoined,
                                    childCurrent: const SignUpScreen()));
                            FirebaseServices.updateActiveStatus(true);
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              isLogging = false;
                            });
                            final msg = e.code;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(msg),
                              backgroundColor: AppStyle.accentColor,
                            ));
                          }
                        } else {
                          showAlert(
                              context: context,
                              title: "Invalid email",
                              content:
                                  "Please enter a valid email to continue.");
                        }
                      } else if (passwordController.text.isEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Password is Empty"),
                                content: const Text("Password cannot be empty"),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      } else if (passwordController.text !=
                          confirmPasswordController.text) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Password don't match"),
                                content: const Text("Password do not match"),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      } else if (!imageAdded) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Image not provided"),
                                content: const Text(
                                    "Please proceed to add your image in order to continue. This is to verify genuineness of the application and the persons."),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      } else if (mobileController.text.length != 10) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Invalid Phone Number"),
                                content: const Text(
                                    "Please enter a valid Phone number to continue."),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      }
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                const Text(
                  "OR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                GestureDetector(
                  onTap: googleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue with  ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: AppStyle.accentColor),
                      ),
                      Image.asset(
                        "images/social.png",
                        scale: 8,
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: const LoginPage(),
                            type: PageTransitionType.bottomToTopJoined,
                            childCurrent: const SignUpScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?  ",
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        "Log in",
                        style: TextStyle(color: AppStyle.accentColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * .05,
                )
              ],
            ),
          ),
        )),
        isLogging
            ? Container(
                height: mq.height,
                width: mq.width,
                color: Colors.black38,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: AppStyle.mainColor,
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
