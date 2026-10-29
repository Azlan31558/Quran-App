import 'package:flutter/material.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() =>
      _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState
    extends State<ZakatCalculatorScreen> {

  final goldController = TextEditingController();
  final silverController = TextEditingController();
  final cashController = TextEditingController();
  final businessController = TextEditingController();
  final debtController = TextEditingController();

  double zakatAmount = 0;

  void calculateZakat() {
    double gold =
        double.tryParse(goldController.text) ?? 0;

    double silver =
        double.tryParse(silverController.text) ?? 0;

    double cash =
        double.tryParse(cashController.text) ?? 0;

    double business =
        double.tryParse(businessController.text) ?? 0;

    double debt =
        double.tryParse(debtController.text) ?? 0;

    double totalAssets =
        gold + silver + cash + business;

    double netAssets =
        totalAssets - debt;

    double zakat = netAssets * 0.025;

    setState(() {
      zakatAmount = zakat;
    });
  }

  Widget buildField(
      String title,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType:
            TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          filled: true,
          fillColor:
              const Color(0xff0A5448),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xff033B33),

      appBar: AppBar(
        backgroundColor:
            const Color(0xff033B33),
        title: const Text(
          "Zakat Calculator",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            buildField(
              "Gold Value",
              goldController,
            ),

            buildField(
              "Silver Value",
              silverController,
            ),

            buildField(
              "Cash Amount",
              cashController,
            ),

            buildField(
              "Business Assets",
              businessController,
            ),

            buildField(
              "Debts",
              debtController,
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xffF4B400),
                ),
                onPressed:
                    calculateZakat,
                child: const Text(
                  "Calculate",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    const Color(0xff0A5448),
                borderRadius:
                    BorderRadius.circular(
                        20),
              ),
              child: Column(
                children: [

                  const Text(
                    "Your Zakat",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    zakatAmount
                        .toStringAsFixed(2),
                    style:
                        const TextStyle(
                      color: Color(
                          0xffF4B400),
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
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