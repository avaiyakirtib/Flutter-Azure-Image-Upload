import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class ImageProperties {
  final String name;
  final String url;
  final String contentType;
  ImageProperties({
    required this.name,
    required this.url,
    required this.contentType,
  });
}

class DownLoadScreen extends StatefulWidget {
  const DownLoadScreen({super.key});

  @override
  State<DownLoadScreen> createState() => _DownLoadScreenState();
}

class _DownLoadScreenState extends State<DownLoadScreen> {
  final String storageAccount = 'demopurpose123';
  final String connectionString =
      'DefaultEndpointsProtocol=https;AccountName=demopurpose123;AccountKey=PeDqYutWvBeosCdtSH/4FmseXjHI1RPL1un0sPyHGP4pcI8Tpnq8CQl3dNod0cPL5JYgJmhJaVBo+AStpc9h0w==;EndpointSuffix=core.windows.net';
  final String containerName = 'demopurposecontainer';
  final List<ImageProperties> imageUrls = [];
  late var contentType;
  bool isLoading = true;
  @override
  void initState() {
    fetchImages();
    super.initState();
  }

  Future<List<ImageProperties>> fetchImages() async {
    final String containerUrl =
        'https://$storageAccount.blob.core.windows.net/$containerName';
    final uri = Uri.parse('$containerUrl?restype=container&comp=list');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody = response.body;
      final document = xml.XmlDocument.parse(responseBody);
      final blobElements = document.findAllElements('Blob');
      for (final blobElement in blobElements) {
        final name = blobElement.findElements('Name').single.text;
        final url = blobElement.findElements('Url').single.text;
        final properties = document.findAllElements('Properties');
        for (final properties in properties) {
          contentType = properties.findElements('Content-Type').single.text;
        }
        imageUrls.add(
            ImageProperties(name: name, url: url, contentType: contentType));
      }
      print(imageUrls.toString());
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
      final response = await http.get(Uri.parse(url));
      final file = File('/storage/emulated/0/Download/$name');
      await file.writeAsBytes(response.bodyBytes);
      print('Image downloaded and saved to $file');

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
          : ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.network(
                        imageUrls[index].url,
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
                                value: (loadingProgress.expectedTotalBytes !=
                                        null)
                                    ? (loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!)
                                    : 0,
                              ),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                          onPressed: () {
                            downloadImageFromAzure(context,
                                imageUrls[index].name, imageUrls[index].url);
                          },
                          child: const Text("Download"))
                    ],
                  ),
                );
              },
            ),
    );
  }
}
