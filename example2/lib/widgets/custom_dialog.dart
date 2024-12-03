import 'package:example2/main.dart';
import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  static Future<bool> showConfirm({
    String title = 'Dialog Title',
    String content = 'Dialog Content',
  }) async {
    final context = getGlobalContext();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        elevation: 5,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: SizedBox(
          width: 50,
          child: MyDialog(title: title, content: content),
        ),
      ),
    );
    return result ?? false;
  }

  static Future<String?> showInput() async {
    TextEditingController textController = TextEditingController();
    final context = getGlobalContext();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('请输入密码'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: '在此输入密码',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // 取消
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, textController.text), // 确定
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildBar(context),
        _buildTitle(),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: _buildContent(),
          ),
        ),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(color: Color(0xff5CC5E9), fontSize: 24),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        content,
        style: const TextStyle(color: Color(0xffCFCFCF), fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFooter(context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15.0, top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Color(0xff73D1EE)),
              child: const Text('Yes',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.orangeAccent),
              child: const Text('Cancle',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(context) => Container(
        height: 30,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(right: 10, top: 5),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.close,
            color: Color(0xff82CAE3),
          ),
        ),
      );
}
