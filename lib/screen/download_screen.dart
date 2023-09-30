import 'dart:io';

import 'package:azureblobdemo/Constant/app_constant.dart';
import 'package:azureblobdemo/Model/getAllImageResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DownLoadScreen extends StatefulWidget {
  const DownLoadScreen({super.key});

  @override
  State<DownLoadScreen> createState() => _DownLoadScreenState();
}

class _DownLoadScreenState extends State<DownLoadScreen> {
  final List<GetAllImageResponseModel> imageUrls = [];

  bool isLoading = true;
  bool isDownloading = false;

  @override
  void initState() {
    getAllImageList();
    super.initState();
  }

  Future<List<GetAllImageResponseModel>> getAllImageList() async {
    final uri = Uri.parse('${AppConstant.baseUrl}/getAllImageList');
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      var data = getAllImageResponseModelFromJson(response.body);
      imageUrls.add(
          GetAllImageResponseModel(message: data.message, images: data.images));
      print(imageUrls.first.images?.toList());
      setState(() {
        isLoading = false;
      });
      return imageUrls;
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  Future<void> downloadImageFromAzure(
      BuildContext context, String name, String url) async {
    try {
      setState(() {
        isDownloading = true;
      });
      final response = await http.get(Uri.parse(url));
      final file = File('/storage/emulated/0/Download/$name');
      await file.writeAsBytes(response.bodyBytes);
      print('Image downloaded and saved to $file');
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image Downloaded'),
          duration:
              Duration(seconds: 2), // How long the Snackbar will be visible
        ),
      );
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image List"),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show the loader while loading.
            )
          : Stack(
              children: [
                ListView.builder(
                  itemCount: imageUrls.first.images?.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.network(
                            imageUrls.first.images![index].url ?? '',
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 100,
                                width: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: (loadingProgress
                                                .expectedTotalBytes !=
                                            null)
                                        ? (loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!)
                                        : 0,
                                  ),
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                              onPressed: () {
                                downloadImageFromAzure(
                                    context,
                                    imageUrls.first.images![index].name ?? '',
                                    imageUrls.first.images![index].url ?? '');
                              },
                              child: const Text("Download"))
                        ],
                      ),
                    );
                  },
                ),
                if (isDownloading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                if (isDownloading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
