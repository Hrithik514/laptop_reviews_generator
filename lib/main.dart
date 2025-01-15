import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProductInputScreen(),
  ));
}

class ProductInputScreen extends StatefulWidget {
  @override
  _ProductInputScreenState createState() => _ProductInputScreenState();
}

class _ProductInputScreenState extends State<ProductInputScreen> {
  final TextEditingController screenSizeController = TextEditingController();
  final TextEditingController ramController = TextEditingController();
  final TextEditingController processorController = TextEditingController();
  final TextEditingController graphicsCardRamController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController graphicsCoprocessorController = TextEditingController();
  final TextEditingController hardDriveController = TextEditingController();
  final TextEditingController processorBrandController = TextEditingController();
  final TextEditingController numProcessorsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Map<String, List<String>> recentInputs = {};

  String apiResponse = "";
  bool isLoading = false;

  void updateRecentInputs(String key, String value) {
    setState(() {
      if (!recentInputs.containsKey(key)) {
        recentInputs[key] = [];
      }
      recentInputs[key]!.remove(value); // Remove if already exists
      recentInputs[key]!.insert(0, value); // Add to the front
      if (recentInputs[key]!.length > 3) {
        recentInputs[key] = recentInputs[key]!.sublist(0, 3); // Keep last 3
      }
    });
  }

  Future<void> submitData() async {
    const String apiUrl = "http://13.60.224.35:5000/generate-review";

    final Map<String, dynamic> data = {
      "screen_size": screenSizeController.text,
      "ram": ramController.text,
      "processor": processorController.text,
      "graphics_card_ram_size": graphicsCardRamController.text,
      "brand": brandController.text,
      "graphics_coprocessor": graphicsCoprocessorController.text,
      "hard_drive": hardDriveController.text,
      "processor_brand": processorBrandController.text,
      "number_of_processors": int.tryParse(numProcessorsController.text) ?? 0,
      "price": priceController.text,
    };

    // Update recent inputs
    data.forEach((key, value) {
      if (value is String && value.isNotEmpty) {
        updateRecentInputs(key, value);
      }
    });

    setState(() {
      isLoading = true;
      apiResponse = "";
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        String review = decodedResponse['review'] ?? "No review available.";
        typewriterEffect(review, delayMilliseconds: 10);
      } else {
        setState(() {
          apiResponse = "Error: ${response.statusCode}. ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void typewriterEffect(String text, {int delayMilliseconds = 50}) async {
    setState(() {
      apiResponse = "";
    });

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
      setState(() {
        apiResponse += text[i];
      });
    }
  }

  Widget buildTextFieldWithSuggestions(
      TextEditingController controller, String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          SizedBox(height: 5),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return (recentInputs[key] ?? [])
                  .where((item) =>
                  item.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textFieldController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return TextField(
                controller: textFieldController..text = controller.text,
                focusNode: focusNode,
                onChanged: (value) {
                  controller.text = value;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Techie - BART',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Give your specifications to Techie - BART',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 30),
                  buildTextFieldWithSuggestions(screenSizeController, 'Screen Size', "screen_size"),
                  buildTextFieldWithSuggestions(ramController, 'RAM', "ram"),
                  buildTextFieldWithSuggestions(processorController, 'Processor', "processor"),
                  buildTextFieldWithSuggestions(
                      graphicsCardRamController, 'Graphics Card RAM Size', "graphics_card_ram_size"),
                  buildTextFieldWithSuggestions(brandController, 'Brand', "brand"),
                  buildTextFieldWithSuggestions(
                      graphicsCoprocessorController, 'Graphics Coprocessor', "graphics_coprocessor"),
                  buildTextFieldWithSuggestions(hardDriveController, 'Hard Drive', "hard_drive"),
                  buildTextFieldWithSuggestions(
                      processorBrandController, 'Processor Brand', "processor_brand"),
                  buildTextFieldWithSuggestions(
                      numProcessorsController, 'Number of Processors', "number_of_processors"),
                  buildTextFieldWithSuggestions(priceController, 'Price', "price"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: submitData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Techie - BART: Writing its Experience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : Text(
                      apiResponse.isNotEmpty
                          ? apiResponse
                          : "",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
