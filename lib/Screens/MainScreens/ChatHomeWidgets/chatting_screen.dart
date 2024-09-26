import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Constants/global_variables.dart';
import '../../../Models/message_model.dart';
import '../../../Models/user_model.dart';
import '../../../Styles/app_style.dart';
import '../../../Widgets/chat_bubble.dart';
import '../../../date_format.dart';
import '../../../image_viewer.dart';
import 'package:http/http.dart' as http;

class ChattingScreen extends StatefulWidget {
  final User user;
  final User chatUser;
  final bool isAdmin;
  final String? adoptionRequest;
  final PetModel? pet;

  const ChattingScreen(
      {super.key,
      required this.user,
      required this.chatUser,
      this.isAdmin = false,
      this.adoptionRequest,
      this.pet});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    sendRequest();
    super.initState();
  }

  sendRequest() async {
    if (widget.adoptionRequest != null && widget.pet != null) {
      for (var image in widget.pet!.images) {
        Message message = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: widget.user.id!,
            receiver: widget.chatUser.id!,
            text: image,
            sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
            readAt: '',
            type: 'image');
        await FirebaseServices.sendMessage(widget.chatUser, message);
      }
      Message message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: widget.user.id!,
          receiver: widget.chatUser.id!,
          text: widget.adoptionRequest!,
          sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
          readAt: '',
          type: 'text');
      await FirebaseServices.sendMessage(widget.chatUser, message);
      await FirebaseServices.sendFirstMessage(chatUser: widget.chatUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () {},
              child: StreamBuilder(
                stream: FirebaseServices.getUserInfo(widget.chatUser),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();
                    case ConnectionState.active:
                    case ConnectionState.done:
                  }
                  final data = snapshot.data!.docs;
                  final list =
                      data.map((e) => User.fromJson(e.data())).toList();
                  final updatedUser = list[0];
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: GestureDetector(
                          onTap: () {
                            if (!widget.isAdmin) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ImageViewer(
                                          title: updatedUser.name,
                                          image: updatedUser.image ??
                                              GlobalVariables.errorImage)));
                            }
                          },
                          child: widget.isAdmin
                              ? const CircleAvatar(
                                  backgroundImage:
                                      AssetImage('images/admin.png'),
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      updatedUser.image ??
                                          GlobalVariables.errorImage),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAdmin ? 'Admin' : updatedUser.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: widget.isAdmin
                                      ? FontWeight.bold
                                      : FontWeight.w500),
                            ),
                            updatedUser.isOnline
                                ? const Text(
                                    'Online',
                                    style: TextStyle(fontSize: 14),
                                  )
                                : Text(
                                    overflow: TextOverflow.fade,
                                    DateFormat.getLastActiveTime(
                                        context: context,
                                        lastActive: updatedUser.lastActive),
                                    style: const TextStyle(fontSize: 14))
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              PopupMenuButton(itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'refresh',
                    onTap: () {
                      setState(() {});
                    },
                    child: const Text("Refresh Chat"),
                  ),
                ];
              }),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                  child: StreamBuilder(
                stream: FirebaseServices.getAllMessages(widget.chatUser),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data!.docs;
                      messages =
                          data.map((e) => Message.fromJson(e.data())).toList();
                      messages = messages.reversed.toList();
                  }
                  return messages.isEmpty
                      ? const Center(
                          child: Text(
                            "Say Hello! 👋",
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onLongPress: () {
                                  messages[index].type != 'text'
                                      ? showMediaOptions(messages[index])
                                      : showOptions(messages[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ChatBubble(
                                    message: messages[index],
                                  ),
                                ));
                          });
                },
              )),
              _chatInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      controller: _messageController,
                      decoration: InputDecoration(
                          hintText: "Type here...",
                          hintStyle: TextStyle(color: AppStyle.accentColor),
                          border: InputBorder.none),
                    )),
                    IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedImage = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedImage != null) {
                            final timeStamp = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref = storage.ref().child(
                                'chats/${FirebaseServices.getConversationId(widget.chatUser.id!)}-$timeStamp');
                            await ref.putFile(File(pickedImage.path));
                            String url = await ref.getDownloadURL();
                            Message message = Message(
                                id: timeStamp,
                                sender: widget.user.id!,
                                receiver: widget.chatUser.id!,
                                text: url,
                                sentAt: timeStamp,
                                readAt: '',
                                type: 'image');
                            FirebaseServices.sendMessage(
                                widget.chatUser, message);
                          }
                        },
                        icon: Icon(
                          size: 26,
                          Icons.image,
                          color: AppStyle.accentColor,
                        )),
                    IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedImage = await picker.pickImage(
                              source: ImageSource.camera);
                          if (pickedImage != null) {
                            final timeStamp = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref = storage.ref().child(
                                'chats/${FirebaseServices.getConversationId(widget.chatUser.id!)}-$timeStamp');
                            await ref.putFile(File(pickedImage.path));
                            String url = await ref.getDownloadURL();
                            Message message = Message(
                                id: timeStamp,
                                sender: widget.user.id!,
                                receiver: widget.chatUser.id!,
                                text: url,
                                sentAt: timeStamp,
                                readAt: '',
                                type: 'image');
                            FirebaseServices.sendMessage(
                                widget.chatUser, message);
                          }
                        },
                        icon: Icon(
                          size: 26,
                          Icons.camera_alt_rounded,
                          color: AppStyle.accentColor,
                        )),
                    SizedBox(
                      width: mq.width * .02,
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: MaterialButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  if (messages.isEmpty) {
                    FirebaseServices.sendFirstMessage(
                        chatUser: widget.chatUser);
                  }
                  String msg = _messageController.text.trim();
                  Message message = Message(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      sender: widget.user.id!,
                      receiver: widget.chatUser.id!,
                      text: msg,
                      sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
                      readAt: '',
                      type: 'text');
                  _messageController.clear();
                  FirebaseServices.sendMessage(widget.chatUser, message);
                  _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut);
                }
              },
              shape: const CircleBorder(),
              minWidth: 25,
              color: AppStyle.accentColor,
              height: 40,
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future showOptions(Message message) {
    final mq = MediaQuery.of(context).size;
    return showModalBottomSheet(
        // backgroundColor:
        // isLightTheme(context) ? LightMode.mainColor : Colors.black,
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            height: mq.height * .48,
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message.text))
                        .then((value) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Message Copied to clipboard"),
                      ));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: Row(
                        children: [
                          Icon(Icons.copy_all),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Copy Text",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      TextEditingController _textController =
                          TextEditingController();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Edit Message"),
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                              content: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _textController,
                                  initialValue: message.text,
                                  onSaved: (text) => message.text = text ?? '',
                                  validator: (text) =>
                                      text != null && text.isNotEmpty
                                          ? null
                                          : "Enter Text",
                                  decoration: InputDecoration(
                                      hintText: "Enter your Message",
                                      label: Text('Message'),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: AppStyle.mainColor,
                                      )),
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        FirebaseServices.firestore
                                            .collection(
                                                '${FirebaseServices.messagesCollection}/${FirebaseServices.getConversationId(widget.chatUser.id!)}/chats/')
                                            .doc(message.id)
                                            .update({"text": message.text});
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text("Update")),
                              ],
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Edit Message",
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) const Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      FirebaseServices.firestore
                          .collection(
                              '${FirebaseServices.messagesCollection}/${FirebaseServices.getConversationId(widget.chatUser.id!)}/chats/')
                          .doc(message.id)
                          .delete();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.delete),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Delete Message",
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Sent At: ${DateFormat.getMessageTime(context: context, time: message.sentAt)}",
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined),
                        SizedBox(
                          width: 20,
                        ),
                        message.readAt.isEmpty
                            ? Text(
                                "Not read yet!",
                              )
                            : Text(
                                "Read At: ${DateFormat.getMessageTime(context: context, time: message.readAt)}",
                              )
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          );
        });
  }

  Future showMediaOptions(Message message) {
    final mq = MediaQuery.of(context).size;
    return showModalBottomSheet(
        // backgroundColor:
        //     isLightTheme(context) ? LightMode.mainColor : Colors.black,
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            height: mq.height * .48,
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message.text))
                        .then((value) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Message Copied to clipboard"),
                      ));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: const Row(
                        children: [
                          Icon(Icons.copy_all),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Copy Link",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // const Divider(),
                // InkWell(
                //   onTap: () => downloadAndSaveImage(message.text),
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Container(
                //       padding: EdgeInsets.symmetric(horizontal: 20),
                //       height: mq.height * .05,
                //       child: Row(
                //         children: [
                //           Icon(Icons.download),
                //           SizedBox(
                //             width: 20,
                //           ),
                //           Text(
                //             "Download Media",
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const Divider(),
                InkWell(
                  onTap: () async {
                    String imageUrl = message.text;
                    final url = Uri.parse(imageUrl);
                    final response = await http.get(url);
                    final bytes = response.bodyBytes;
                    final temp = await getTemporaryDirectory();
                    final path = '${temp.path}/image.png';
                    File(path).writeAsBytesSync(bytes);
                    await Share.shareXFiles([XFile(path)], text: 'Check out this image I found on Pet Match App');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: const Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Share Media to another app",
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      FirebaseServices.firestore
                          .collection(
                              '${FirebaseServices.messagesCollection}/${FirebaseServices.getConversationId(widget.chatUser.id!)}/chats/')
                          .doc(message.id)
                          .delete();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.delete),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Delete Media File",
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Sent At: ${DateFormat.getMessageTime(context: context, time: message.sentAt)}",
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined),
                        SizedBox(
                          width: 20,
                        ),
                        message.readAt.isEmpty
                            ? Text(
                                "Not read yet!",
                              )
                            : Text(
                                "Read At: ${DateFormat.getMessageTime(context: context, time: message.readAt)}",
                              )
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          );
        });
  }

  // Future<Uint8List?> downloadImage(String imageUrl) async {
  //   try {
  //     // Download the image data from the URL
  //     final response = await http.get(Uri.parse(imageUrl));
  //     if (response.statusCode == 200) {
  //       return response.bodyBytes; // Return the image as bytes
  //     } else {
  //       print('Failed to download image');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error downloading image: $e');
  //     return null;
  //   }
  // }
  //
  // Future<String?> saveImageToGallery(Uint8List imageData, String fileName) async {
  //   try {
  //     // Request storage permission if on Android
  //     bool isGranted = await requestStoragePermission();
  //     if (Platform.isAndroid) {
  //       if (!isGranted) {
  //         PermissionStatus status = await Permission.storage.request();
  //         if(status.isGranted) {
  //           saveImageToGallery(imageData, fileName);
  //         }
  //         print("Storage permission is required");
  //         return null;
  //       }
  //     }
  //
  //
  //     // Get the directory to save the image
  //     Directory? directory;
  //     if (Platform.isAndroid) {
  //       directory = Directory('/storage/emulated/0/Pet Match/Pictures'); // Public Pictures folder on Android
  //     } else if (Platform.isIOS) {
  //       directory = await getApplicationDocumentsDirectory(); // Internal storage for iOS
  //     }
  //
  //     // Ensure the directory exists
  //     if (!directory!.existsSync()) {
  //       directory.createSync(recursive: true);
  //     }
  //
  //     // Create the full file path where the image will be saved
  //     String filePath = path.join(directory.path, fileName);
  //
  //     // Save the image as a file
  //     File imageFile = File(filePath);
  //     await imageFile.writeAsBytes(imageData);
  //
  //     // For iOS, handle platform-specific logic to add the image to Photos library (not covered here)
  //     if (Platform.isIOS) {
  //       print('Saved to app-specific storage. For gallery access, use platform-specific APIs.');
  //       // iOS: Use platform channels or a plugin to save to the Photos gallery.
  //     }
  //
  //     return filePath;  // Return the file path where the image was saved
  //   } catch (e) {
  //     print('Error saving image: $e');
  //     return null;
  //   }
  // }
  //
  //
  //
  // void downloadAndSaveImage(String imageUrl) async {
  //   Uint8List? imageData = await downloadImage(imageUrl);
  //   String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   if (imageData != null) {
  //     String? filePath = await saveImageToGallery(imageData, '$timestamp.jpg');
  //     Navigator.pop(context);
  //     if (filePath != null) {
  //       print('Image saved at: $filePath');
  //     } else {
  //       print('Failed to save image');
  //     }
  //   } else {
  //     print('Failed to download image');
  //   }
  // }
  //
  // Future<bool> requestStoragePermission() async {
  //   // Check if storage permission is already granted
  //   if (await Permission.storage.isGranted) {
  //     return true;
  //   } else {
  //     // Request storage permission
  //     PermissionStatus status = await Permission.storage.request();
  //
  //     // Return true if permission is granted, otherwise false
  //     if (status.isGranted) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  // }
}
