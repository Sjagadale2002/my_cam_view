import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CCTVStreamScreen(),
    );
  }
}

class CCTVStreamScreen extends StatefulWidget {
  @override
  _CCTVStreamScreenState createState() => _CCTVStreamScreenState();
}

class _CCTVStreamScreenState extends State<CCTVStreamScreen> {
  late List<VlcPlayerController> _controllers;
  final List<String> _defaultStreamUrls = [
    // Keep you url here
    //add your camera rtsp url here 
  ];
  List<String> _currentStreamUrls = [];

  TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStreamUrls = List.from(_defaultStreamUrls);
    _controllers = List.generate(
      _currentStreamUrls.length,
          (index) => VlcPlayerController.network(
        _currentStreamUrls[index],
        autoPlay: true,
        options: VlcPlayerOptions(),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to add a new camera URL
  void _addNewCamera(String url) {
    setState(() {
      _currentStreamUrls.add(url);
      _controllers.add(VlcPlayerController.network(
        url,
        autoPlay: true,
        options: VlcPlayerOptions(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CCTV Camera Streams"),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 250,
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: "Enter RTSP URL",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      String url = _urlController.text.trim();
                      if (url.isNotEmpty) {
                        _addNewCamera(url);
                      }
                      _urlController.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two cameras in each row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to full-screen mode when a camera is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenStreamScreen(
                    rtspUrl: _currentStreamUrls[index],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[800],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: VlcPlayer(
                      controller: _controllers[index],
                      aspectRatio: 16 / 9,
                      virtualDisplay: true,
                      placeholder: Center(child: CircularProgressIndicator()), // Loading indicator
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Cam ${index + 1}', // Camera name (e.g. Cam1, Cam2)
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenStreamScreen extends StatelessWidget {
  final String rtspUrl;

  FullScreenStreamScreen({required this.rtspUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Full Screen Stream'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: VlcPlayer(
          controller: VlcPlayerController.network(
            rtspUrl,
            autoPlay: true,
            options: VlcPlayerOptions(),
          ),
          aspectRatio: MediaQuery.of(context).size.width /
              MediaQuery.of(context).size.height,
          virtualDisplay: true,
        ),
      ),
    );
  }
}
