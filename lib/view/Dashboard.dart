import 'package:flutter/material.dart';
import '../database/InilizeDb.dart';
import 'AddNewItem.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final dbHelper = DatabaseHelper();
  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;
  List<Map<String, dynamic>> expenses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _fetchExpenses(); // Fetch expenses when the dependencies change
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    nameController.dispose();
    titleController.dispose();
    amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh the data when returning to this page
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final data = await dbHelper.getExpenses();
    setState(() {
      expenses = data;
    });
    print("data value....${data}");
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: expenses.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Dismissible(
                    key: Key(expense['id'].toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteExpense(expense['id']);
                    },
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xffB2DFDB),
                        ),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpensesDetails(
                                  indexvalue: index,
                                  title: expense['name'],
                                  date: expense['title'],
                                  id:expense["id"]
                                )),
                          );
                          if (result == true) {
                            _fetchExpenses();
                          }
                        },
                        child: ListTile(
                          title: Text(expense['name'],
                          style: TextStyle(color: Colors.black,fontSize:15, fontWeight: FontWeight.w500 )
                            ,),
                          subtitle: Text('Date: ${expense['title']}',
                              style: TextStyle(color: Colors.black,fontSize:15, fontWeight: FontWeight.w400 )
                          ),
                          trailing: Text('Amount: ${expense['amount']}',
                              style: TextStyle(color: Colors.black,fontSize:15, fontWeight: FontWeight.w400 )
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showExpenseDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _insertData() async {
    final expense = {
      'name': nameController.text,
      'title': _dateController.text,
      'amount': 0
    };
    await dbHelper.insertExpense(expense);
    nameController.clear();
    _dateController.clear();
    Navigator.of(context).pop(true); // Pop with a result to indicate success
    _fetchExpenses(); // Fetch expenses after inserting a new one
  }

  void _deleteExpense(int id) async {
    await dbHelper.deleteExpense(id);
    _fetchExpenses(); // Refresh the list after deleting an expense
  }

  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Expenses'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Select Date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _insertData,
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
