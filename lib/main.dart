import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iconly/iconly.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  MyTodoBox._todoBox = Hive.box('todoBox');
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
    List tempList = [];
    if(MyTodoBox._todoBox.toMap().length!=0) {
      MyTodoBox._todoBox.toMap().forEach((k, v) => {tempList.add(v)});
      print(MyTodoBox._todoBox.toMap());
    }
    print(tempList);
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color(0xffe2eff1),
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
                        // textField
                        Flexible(
                          flex: 3,
                          child: TextField(
                            onTapAlwaysCalled: true,
                            controller: MyTodoBox.currTxt,
                            onSubmitted: (value) {
                              setState(() {
                                if(MyTodoBox.currTxt.text!="") {
                                  MyTodoBox().addTodo([MyTodoBox.currTxt.text, false]);
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
                                focusedBorder: OutlineInputBorder(
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
                                  MyTodoBox().addTodo([MyTodoBox.currTxt.text, false]);
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
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: tempList.length,
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
                                  MyTodoBox._todoBox.putAt(
                                      MyTodoBox._todoBox.toMap().keys.firstWhere(
                                              (k)=>MyTodoBox._todoBox[k][0]
                                          == tempList[index][0],
                                        orElse: ()=> null
                                      ),
                                      [(tempList[index][0]),
                                        (!tempList[index][1])]
                                  );
                                  });
                                },
                                child: AutoSizeText(
                                  "• ${tempList[index][0]}",
                                  style: TextStyle(
                                      color: tempList[index][1]?
                                      const Color(0xff7a7a7a): const Color(0xff456672),
                                      fontSize: 30,
                                      decoration: tempList[index][1]
                                          ? TextDecoration.lineThrough
                                          : null
                                  ),
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
                                    setState(() async {
                                      MyTodoBox.currTxt.text = tempList[index][0];
                                      await MyTodoBox().removeTodo(tempList[index]);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xff555273),
                                    size: 30,
                                  )),
                            ),
                            // remove button
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() async {
                                      await MyTodoBox().removeTodo(tempList[index]);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
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
    MyTodoBox._todoBox.close();
    Hive.close();
  }
}

class MyTodoBox {
  static var currTxt = TextEditingController();
  static late final _todoBox;

  Future<void> addTodo(List l) async {
    bool b = true;
    _todoBox.toMap().forEach((k, v) => {if(v[0]==l[0]){b=false}});
    if(b) {
      await _todoBox.add(l);
    }
  }

  Future<void> removeTodo(List l) async {
    _todoBox.toMap().forEach((k, v) async => {if(v==l){await _todoBox.delelte(k)}});
  }
}
