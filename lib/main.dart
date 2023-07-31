import 'package:flutter/material.dart';
import 'package:sqlite_tutorial/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLITE Tutorial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _journals = [];


  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _refreshItems() async {
    await DbHelper.getItems().then((data) {
      setState(() {
        _journals = data;
      });
    });
  }

  Future<void> _updateItem(int id) async {
    await DbHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    await _refreshItems();
  }

  Future<void> _addItem() async {
    await DbHelper.createItem(
        _titleController.text, _descriptionController.text);
    await _refreshItems();
  }

  Future<void> _deleteItem(int id) async {
    await DbHelper.deleteItem(id);
    await _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deleting item succesfuly!')));
  }

  @override
  void initState() {
    _refreshItems();
    print('.. number of items : ${_journals.length}');
    super.initState();
  }

  void _showForm(int? id) {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
            right: 15,
            left: 15,
            top: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'description'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                if (id != null) {
                  await _updateItem(id);
                } else {
                  await _addItem();
                }

                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: const Text('Submit')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLITE'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _journals.length,
        itemBuilder: (context, index) => ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(_journals[index]['title']),
          subtitle: Text(_journals[index]['description']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    _showForm(_journals[index]['id']);
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    _deleteItem(_journals[index]['id']);
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
