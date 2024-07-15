import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/InilizeDb.dart';

class ExpensesDetails extends StatefulWidget {
  final int indexvalue;
  final String? title;
  final String date;
  final int id;

  const ExpensesDetails({
    super.key,
    required this.indexvalue,
    this.title,
    required this.date,
    required this.id,
  });

  @override
  State<ExpensesDetails> createState() => _ExpensesDetailsState();
}

class _ExpensesDetailsState extends State<ExpensesDetails> {
  final dbHelper = DatabaseHelper();
  final descriptionController = TextEditingController();
  final amountCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  var totolamount;
  var id;
  final _formKey = GlobalKey<FormState>(); // Add form key

  void _queryAllAnotherTable() async {
    final anotherTable = await dbHelper.getAnotherTable();
    print('All anotherTable: $anotherTable');
    setState(() {}); // Refresh the UI
  }

  void _insertAnotherData() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameCtrl.text,
        'description': descriptionController.text,
        'value': amountCtrl.text,
        'uniqueID': widget.indexvalue
      };
      await dbHelper.insertAnotherTable(data);
      await updateData();

      setState(() {}); // Refresh the UI
    }
  }

  List<Map<String, dynamic>> getdata = [];
  List<Map<String, dynamic>> expenses = [];

  Future<void> updateData() async {
    var myInt = int.parse(amountCtrl.text.toString());
    var sum = totolamount + myInt;
    print("sum value...${id}......${widget.indexvalue}");
    await dbHelper.updateData(widget.indexvalue, {
      'id': widget.id,
      'name': widget.title,
      'title': widget.date,
      'amount': sum
    });

    descriptionController.clear();
    nameCtrl.clear();
    amountCtrl.clear();
    final data = await dbHelper.getExpenses();
    setState(() {
      expenses = data;
    });

    print("total amount...${data}");

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _queryAllAnotherTable();
    print("index value...${widget.indexvalue}");
    print("total amount...${totolamount}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: dbHelper.getData(widget.indexvalue),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No data found'));
                } else {
                  var expensesItem = snapshot.data?['expensesItem'];
                  totolamount = snapshot.data?['totalValue'];
                  id = snapshot.data?['id'];
                  print("total value maotunt......${totolamount}");
                  var expenseTableList =
                  snapshot.data?['expensetable'] as List<Map<String, dynamic>>?;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ' ${expensesItem['name']}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFBA68C8) ,// Border color
                                 width: 3, // Border width
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                if (expenseTableList != null && expenseTableList.isNotEmpty) ...[
                                  for (var expensetable in expenseTableList) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: Color(0xffB2DFDB),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          'Description: ${expensetable['description']}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Amount: ${expensetable['value']}',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            Text(
                                              'Name: ${expensetable['name']}',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(), // Add a divider between items
                                  ]
                                ] else
                                  ListTile(
                                    title: Text('No data found for Expense Table'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            Form(
              key: _formKey, // Add form key to Form widget
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xFFBA68C8), // Border color
                      width: 3, // Border width
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: amountCtrl,
                          decoration: InputDecoration(labelText: 'Amount'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF81C784), // Background color
                          ),
                          onPressed: _insertAnotherData,
                          child: Text(
                            'Submit the Expenses',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
