
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  List<Map<String, dynamic>> todos = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async{
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('todos');
    if (saved != null){
      final decoded = jsonDecode(saved) as List;

      setState(() {
        todos = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', jsonEncode(todos));
  }

  void _addTodo(String text){
    if (text.trim().isEmpty) return;

    setState(() {
      todos.add({"text":text.trim(), "done": false});
      _controller.clear();
    });
    _saveTodos();
  }

  void _deleteTodo(int index) async{
    final removed = todos[index]['text'];
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${removed} 삭제됨"))
    );
  }

  void _togleDone(int index, bool? value){
    setState(() {
      todos[index]['done'] = value ?? false;
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do 앱"),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _addTodo,
                      decoration: InputDecoration(
                        hintText: "할 일을 입력하세요",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        filled: true,
                        fillColor: Colors.pink[50]
                      ),
                    )
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => _addTodo(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white
                    ),
                    child: const Text("추가")
                ),
              ],
            ),
          ),
          Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text("할 일이 없습니다."))
                  : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index){
                    final todo = todos[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4
                      ),
                      child: ListTile(
                        leading: Checkbox(
                            value: todo['done'],
                            onChanged: (value) => _togleDone(index, value),
                        ),
                        title: Text(
                          todo['text'],
                          style: TextStyle(
                            fontSize: 18,
                            decoration: todo['done']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                              color: todo['done'] ? Colors.grey : Colors.black
                          ),
                        ),
                        onLongPress: () => _deleteTodo(index),
                      ),
                    );
                  }
              )
          )
        ],
      ),
    );
  }
}