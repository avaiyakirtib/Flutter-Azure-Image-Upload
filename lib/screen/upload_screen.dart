// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constant/index.dart';
import '../model/upload_image_model.dart';
import 'download_screen.dart';


class UploadScreen extends StatefulWidget {
  const UploadScreen({
    super.key,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
//==============================================================================
// ** Property **
//==============================================================================

  final picker = ImagePicker();
  late XFile? pickedFile;
  bool isLoading = false;

  Future<void> _takePicture(BuildContext context, ImageSource source) async {
    pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      await uploadImageToAzure(context);
    }
  }

  Future uploadImageToAzure(context) async {
    try {
      setState(() {
        isLoading = true;
      });
      String path = pickedFile?.path ?? "";
      uploadImage(image: io.File(path)).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message ?? ""),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          isLoading = false;
        });
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  Future<UploadImageModel> uploadImage({
    required File image,
  }) async {
    String url = "${AppConstant.baseUrl}/uploadImage";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    var filePath = image.path;
    int lastSlashIndex = filePath.lastIndexOf('/');
    String filename = filePath.substring(lastSlashIndex + 1);
    request.files.add(
      http.MultipartFile.fromString(
        'image',
        image.path,
      ),
    );
    List<int> byteData = await image.readAsBytes();
    http.MultipartFile multipartFile =
        http.MultipartFile.fromBytes('image', byteData, filename: filename);
    request.files.add(multipartFile);
    var response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final parsedJson = json.decode(responseBody);
      return UploadImageModel.fromJson(parsedJson);
    } else {
      throw Exception('Failed to get Category Data.');
    }
  }
//==============================================================================
// **  Life Cycle **
//==============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(AppString.demoName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (alertContext) {
                      return AlertDialog(
                        title: const Text('Select Image Source'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('Take Picture'),
                              onTap: () {
                                Navigator.of(alertContext).pop();
                                _takePicture(context, ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text('Pick from Gallery'),
                              onTap: () {
                                Navigator.of(alertContext).pop();
                                _takePicture(context, ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text("Upload")),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DownLoadScreen()));
                },
                child: const Text("Download")),
            const SizedBox(
              height: 10,
            ),
            isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

//==============================================================================
// ** Main Widget **
//==============================================================================

//==============================================================================
// ** Helper Widget **
//==============================================================================

//==============================================================================
// ** Api Call **
//==============================================================================

}
