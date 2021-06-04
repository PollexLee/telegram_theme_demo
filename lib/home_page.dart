import 'package:flutter/material.dart';
import 'package:telegram_theme_demo/my_theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var model = context.read<MyThemeModel>();
    return Scaffold(
      backgroundColor: model.customTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: model.customTheme.backgroundColor,
        title: Text('Telegram Theme Demo', style: TextStyle(color: model.customTheme.titleColor)),
        actions: [
          IconButton(
            key: key,
            icon: Icon(
              Icons.wb_sunny,
              color: model.customTheme.iconColor,
            ),
            onPressed: () {
              RenderBox ro = key.currentContext.findRenderObject() as RenderBox;
              var offset = ro.localToGlobal(Offset.zero);
              var size = ro.size;
              // 1. 截图并显示到自绘组件上

              // 2. 修改主题
              model.switchTheme(offset: offset.translate(size.width / 2, size.height / 2));

              // 3. 启动切换动画
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('title $index', style: TextStyle(color: model.customTheme.titleColor)),
              leading: Icon(Icons.beach_access, color: model.customTheme.iconColor),
              trailing: Icon(Icons.favorite, color: model.customTheme.iconColor),
            );
          }),
    );
  }
}
