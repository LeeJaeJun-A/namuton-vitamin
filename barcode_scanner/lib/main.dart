import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Ensuring Flutter engine initialization.
  await Firebase.initializeApp(); // Initializing Firebase.
  runApp(const MyApp()); // Running the app.
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); 
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Setting the home to SplashScreen widget.
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key); // Constructor for MyHomePage.
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Creating state for MyHomePage.
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime date = DateTime.now(); // Initializing the current date.
  final firestore = FirebaseFirestore.instance; // Instance of Firestore.
  ScanController controller = ScanController(); // Controller for barcode scanner.
  var _documentSnapshot; // To store document snapshot from Firestore.
  var _data; // To store data fetched from Firestore. 
  var _result = '상품 인식 중'; // Initial result text.
  bool _isAvailable = true; // Whether the barcode date passes the expiration date or not
  var _scanResult = ''; // for saving the scanned barcode number
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Getting device height.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: height * 0.065,
            ),
            _buildBarcodeScanner(),
            SizedBox(height: height * 0.015,),
            const Text(
              '상품 소비 날짜',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide.none,
              ),
              backgroundColor: Colors.white,
              ),
              child: 
                Text('${date.year}.${date.month}.${date.day}', style: const TextStyle(fontSize: 24, color: Colors.black)),// Displaying the date.
              onPressed: () async{
                DateTime? newDate = await showDatePicker(
                  context: context, 
                  firstDate: DateTime(date.year), 
                  lastDate: DateTime(2300),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                );
                if(newDate == null) return;
                setState(() => date = newDate); // Updating the date when the date is changed.
              },
            ),
            SizedBox(height: height * 0.015,),
            Expanded(
              child:Container(
              color:_result == '상품 인식 중' ? Color.fromARGB(200, 232, 232, 232) : 
              (_isAvailable == true ? Color.fromARGB(200, 170,248,150): Color.fromARGB(200, 255, 132, 132)), // Changing color based on product availability.
              alignment: Alignment.center,
              child: Text(
                  _result == '상품 인식 중' ? _result : _result + ' 까지 소비 가능',
                  style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the barcode scanner.
  Widget _buildBarcodeScanner() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.715,
      child: ScanView(
        controller: controller,
        scanAreaScale: .7,
        scanLineColor: Colors.white,
        onCapture: (data) { // Function to handle barcode capture.
          setState(() {
            _scanResult = data; // Updating scan result.
          });
          getData(_scanResult); // Fetching data from Firestore.
          controller.resume(); // Resuming scanner.
        },
      ),
    );
  }

  Future<void> getData(String scanResult) async {
  _documentSnapshot = await firestore.collection('barcode').doc(scanResult).get();
  _data = _documentSnapshot.data();
  if (_data != null) {
    setState(() {
      _result = _data['expiration_date']; // Updating result with expiration date.
      // Parsing date from the barcode.
      int barcodeYear = int.parse(_result.substring(0,4));
      int barcodeMonth = int.parse(_result.substring(5,7));
      int barcodeDay = int.parse(_result.substring(8,10));

      // Checking if the product is expired.
      if(date.year > barcodeYear){
        _isAvailable = false;
      }else if(date.year == barcodeYear && date.month > barcodeMonth){
        _isAvailable = false;
      }else if(date.year == barcodeYear && date.month == barcodeMonth && date.day > barcodeDay){
        _isAvailable = false;
      }else{
        _isAvailable = true;
      }
    });
  }
}
}

// Splash screen widget.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();  // Navigating to home screen after splash screen.
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2), () {}); // Waiting for 2 seconds.
    Navigator.pushReplacement( // Navigating to MyHomePage.
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/splash.png'), 
      ),
    );
  }
}
