import 'package:azblob/azblob.dart';
import 'package:azureblobdemo/download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Azure blob storage demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  late XFile? pickedFile;
  final String storageAccount = 'demopurpose123';
  final String connectionString =
      'DefaultEndpointsProtocol=https;AccountName=demopurpose123;AccountKey=PeDqYutWvBeosCdtSH/4FmseXjHI1RPL1un0sPyHGP4pcI8Tpnq8CQl3dNod0cPL5JYgJmhJaVBo+AStpc9h0w==;EndpointSuffix=core.windows.net';
  final String containerName = 'demopurposecontainer';
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
      String fileName = basename(pickedFile!.path);
      // read file as Uint8List
      Uint8List content = await pickedFile!.readAsBytes();
      var storage = AzureStorage.parse(connectionString);
      // get the mine type of the file
      String? contentType = lookupMimeType(fileName);
      await storage.putBlob('/$containerName/$fileName',
          bodyBytes: content,
          contentType: contentType,
          type: BlobType.blockBlob);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image Uploaded'),
          duration: Duration(seconds: 2),
        ),
      );
    } on AzureStorageException catch (ex) {
      setState(() {
        isLoading = false;
      });
      print(ex.message);
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                        title: Text('Select Image Source'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('Take Picture'),
                              onTap: () {
                                Navigator.of(alertContext).pop();
                                _takePicture(context, ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.image),
                              title: Text('Pick from Gallery'),
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
}
