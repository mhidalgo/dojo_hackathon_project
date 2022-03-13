import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/nftport_poc/mint_nft_screen.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;



class UploadToIPFS extends StatefulWidget {
  const UploadToIPFS({Key? key,
  required this.videoFile,
  required this.videoFilePath
  }) : super(key: key);

  final String videoFilePath;
  final File videoFile;

  @override
  _UploadToIPFSState createState() => _UploadToIPFSState();
}

class _UploadToIPFSState extends State<UploadToIPFS> {

  late VideoPlayerController _controller;
  CollectionReference ipfsUrls = FirebaseFirestore.instance.collection('ipfsUrls');
  String videoUrl = '';




  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    print('upload ipfs file path: ${widget.videoFilePath}');
  }

  @override
  void dispose(){
    super.dispose();
    _controller.dispose();

  }

  ///Functions
  backButtonAction() {
    Navigator.pop(context);
  }

  Future<void> upload(File imageFile) async {

    Map<String, String> headers = { "Authorization": "249a4ff4-846d-426a-9280-26c36a5952ca"}; //key for NFTPort
    //String videoUrl = '';

    // open a bytestream
    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("https://api.nftport.xyz/v0/files");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: imageFile.path);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);


    // listen for response
   /*response.stream.transform(utf8.decoder).listen((value) {
      Map ipfsJSON = jsonDecode(value);
      videoUrl = ipfsJSON['ipfs_url'];
      print(videoUrl);
    });*/

      await response.stream.bytesToString().then((value) {
        Map ipfsJSON = jsonDecode(value);
        videoUrl = ipfsJSON['ipfs_url'];
        print(videoUrl);
      });
    //return videoUrl;
  }

  //Post URL and minted status to Firebase Collection for testing
  Future<void> postIpfsUrl(String? videoUrl) async {
    return ipfsUrls
        .add({
      'url': videoUrl, // IPFS Url
    })
        .then((value) => print("URL added"))
        .catchError((error) => print("Failed to add URL: $error"));
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print('tap');
              backButtonAction();
            },
          ),
        ),
        body: Stack(
            children: <Widget>[_controller.value.isInitialized
              ?  VideoPlayer(_controller)
              : Container(),
              Positioned(
                bottom:20,
                child: HighEmphasisButton(title: 'Send to IPFS',
                    onPressAction: () async {
                     await upload(widget.videoFile);
                     print('THIS IS THE NFT URL $videoUrl');
                     await postIpfsUrl(videoUrl);
                     Navigator.of(context).push(MaterialPageRoute(builder: (context) => MintNft(videoUrl: videoUrl)));
                    }
                ),
              ),
        ]
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
