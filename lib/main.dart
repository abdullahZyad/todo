import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iconly/iconly.dart';

void main() async {
  await Hive.initFlutter();
  MyTodoBox.mybox = await Hive.openBox('todoBox');
  MyTodoBox.mybox.get('todoList')==null? MyTodoBox.mybox.put('todoList', []) : null;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MaterialApp(
    localizationsDelegates: [
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      Locale("ar", "KSA"),
    ],
    locale: Locale("ar", "KSA"),
    debugShowCheckedModeBanner: false,
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    Hive.openBox('todoBox');
    return SafeArea(
      child: Scaffold(
          backgroundColor: (DateTime.now().hour > 20 || DateTime.now().hour < 4)
              ? const Color(0xff555273)
              : const Color(0xffe2eff1),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,20,0,0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // textfield
                        Flexible(
                          flex: 3,
                          child: TextField(
                            onTapAlwaysCalled: true,
                            controller: MyTodoBox.currTxt,
                            onSubmitted: (value) {
                              setState(() {
                                if(MyTodoBox.currTxt.text!="") {
                                  MyTodoBox().addTodo(MyTodoBox.currTxt.text, false);
                                  MyTodoBox.currTxt.text = "";
                                }
                              });
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff456672), width: 2.0),
                                ),
                                labelText: 'اكتب مهمتك الجديدة',
                                labelStyle: TextStyle(color: Color(0xff456672)),
                                fillColor: Color(0xff000000)),
                          ),
                        ),
                        // add button
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(
                              IconlyBold.plus,
                              size: 30,
                              color: Color(0xff456672),
                            ),
                            onPressed: () {
                              setState(() {
                                if(MyTodoBox.currTxt.text!="") {
                                  MyTodoBox().addTodo(MyTodoBox.currTxt.text, false);
                                  MyTodoBox.currTxt.text = "";
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                    flex: 5,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: MyTodoBox.mybox.get('todoList').length == 0
                            ? 0
                            : MyTodoBox.mybox.get('todoList').length,
                        itemBuilder: (context, index) => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // show todo
                            Flexible(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                  MyTodoBox.mybox.get('todoList')[index][1] =
                                      !MyTodoBox.mybox.get('todoList')[index][1];
                                  });
                                },
                                child: AutoSizeText(
                                  "- ${MyTodoBox.mybox.get('todoList')[index][0]}",
                                  style: TextStyle(
                                      color: MyTodoBox.mybox.get('todoList')[index][1]?
                                      Color(0xff7a7a7a): Color(0xff456672),
                                      fontSize: 30,
                                      decoration: MyTodoBox.mybox
                                              .get("todoList")[index][1]
                                          ? TextDecoration.lineThrough
                                          : null),
                                  maxFontSize: 50,
                                  minFontSize: 5,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                            // edit button
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      MyTodoBox.currTxt.text = MyTodoBox.mybox
                                          .get('todoList')[index][0];
                                      MyTodoBox().removeTodo(index);
                                    });
                                  },
                                  icon: const Icon(
                                    IconlyBold.edit,
                                    color: Color(0xff555273),
                                    size: 30,
                                  )),
                            ),
                            // remove button
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      MyTodoBox().removeTodo(index);
                                    });
                                  },
                                  icon: const Icon(
                                    IconlyBold.delete,
                                    color: Color(0xffda5151),
                                    size: 30,
                                  )),
                            )
                          ],
                        ),
                      ))
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    MyTodoBox.mybox.close();
  }
}

class MyTodoBox {
  static var currTxt = TextEditingController();
  static var mybox = Hive.box('todoBox');

  void addTodo(String todo, bool isDone) async {
    mybox.get('todoList').add([todo, isDone]);
  }

  void removeTodo(int index) async {
    mybox.get('todoList').removeAt(index);
  }
}
