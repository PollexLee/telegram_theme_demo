import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:telegram_theme_demo/circle_clipper.dart';

class TgThemeWidget extends StatefulWidget {
  TgThemeWidget({this.child, this.controller});
  final Widget child;
  final TgThemeController controller;

  @override
  State<StatefulWidget> createState() {
    return TgThemeState();
  }
}

class TgThemeState extends State<TgThemeWidget> with TickerProviderStateMixin {
  TgThemeState();
  GlobalKey repaintWidgetKey = GlobalKey(); // 绘图key值
  ui.Image backImage;
  ui.Image frontImage;
  bool isNormal = true;
  // bool isAnim = false;
  ThemeChangeType _captureType = ThemeChangeType.IDLE;

  // Uint8List bytes;
  AnimationController animationController;
  AnimationController childAnimController;

  Offset circleOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.registerCapture(({Offset offset}) async {
      if (_captureType != ThemeChangeType.IDLE) {
        return;
      }
      _captureType = ThemeChangeType.CAPTURING;
      debugPrint('开始截屏');
      circleOffset = offset;
      RenderRepaintBoundary boundary = repaintWidgetKey.currentContext.findRenderObject();
      double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
      // boundary.to
      ui.Image image = await boundary.toImage(pixelRatio: dpr);
      // normal：缩放child，image当背景
      // 非normal: 缩放image, child当背景
      if (isNormal) {
        backImage = image;
      } else {
        frontImage = image;
      }
      _captureType = ThemeChangeType.CAPTURE_FINISH;
      setState(() {});
    });

    widget.controller.registerStartAnim(() {
      if (_captureType != ThemeChangeType.CAPTURE_FINISH) {
        return;
      }
      _captureType = ThemeChangeType.ANIMATING;
      debugPrint('开始执行动画');
      if (isNormal) {
        setState(() {});
        childAnimController.forward(from: 0.0);
      } else {
        setState(() {});
        animationController.reverse(from: 1.0);
      }
    });

    animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    childAnimController = AnimationController(value: 1, duration: Duration(milliseconds: 300), vsync: this);

    ///监听动画的改变
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // animationController.reverse();
        _captureType = ThemeChangeType.IDLE;
        animationController.reset();
        setState(() {
          isNormal = true;
          frontImage = null;
          backImage = null;
        });
      }
    });

    childAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _captureType = ThemeChangeType.IDLE;
        setState(() {
          isNormal = false;
          frontImage = null;
          backImage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintWidgetKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: ui.window.physicalSize.height,
            width: ui.window.physicalSize.width,
            child: CustomPaint(
              painter: ImagePainter(backImage),
            ),
          ),
          AnimatedBuilder(
            animation: childAnimController,
            builder: (ctx, child) {
              return ClipOval(
                clipper: CircularClipper(percentage: childAnimController?.value, offset: circleOffset),
                child: child,
              );
            },
            child: widget.child,
          ),
          AnimatedBuilder(
            animation: animationController,
            builder: (ctx, child) {
              return ClipOval(
                clipper: CircularClipper(percentage: animationController?.value, offset: circleOffset),
                child: child,
              );
            },
            child: Container(
              height: ui.window.physicalSize.height,
              width: ui.window.physicalSize.width,
              child: CustomPaint(
                painter: ImagePainter(frontImage),
              ),
            ),
          ),
        ],
      ),
      // child: CustomPaint(
      //   foregroundPainter: CapturePainter(image),
      //   child: widget.child,
      // ),
    );
  }
}

class CapturePainter extends CustomPainter {
  CapturePainter(this.image);
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // paint.blendMode = BlendMode.dstOut;
    if (image != null) {
      print('size = $size');
      Paint paint = Paint();
      // canvas.
      paint.blendMode = BlendMode.srcOut;
      // paint.color = Colors.yellow;
      final List<RSTransform> transforms = <RSTransform>[
        RSTransform.fromComponents(rotation: 0, scale: 0.3, anchorX: 0, anchorY: 0, translateX: 0, translateY: 0)
      ];
      // 绘制图片
      // canvas.save();
      Paint circlePaint = Paint();
      // circlePaint.color = Colors.transparent;
      circlePaint.blendMode = BlendMode.dstOut;
      canvas.drawCircle(Offset.zero, 500, circlePaint);
      // canvas.saveLayer(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), paint);
      // canvas.clipRect(Rect.fromCenter(center: Offset.zero, width: 500, height: 500));
      canvas.drawAtlas(image, transforms, <Rect>[Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble())],
          <Color>[Colors.transparent], BlendMode.src, null, paint);
      // canvas.drawImage(image, offset, paint)
      // canvas.drawColor(Colors.transparent, BlendMode.dstOut);
      // canvas.restore();

      // 保存图片图层
      // canvas.saveLayer(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), paint);
      // canvas.restore();

      // canvas.save();
      // canvas.restore();
      // canvas.restore();
      // canvas.restore();
      // canvas.saveLayer(null, paint);

      // canvas.restore();
      // canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TgThemeController {
  Function({Offset offset}) _capture;
  Function() _startnim;
  // 注册Widget，当调用截图方法时，调用所有widget
  registerCapture(Function({Offset offset}) function) {
    this._capture = function;
  }

  registerStartAnim(Function() function) {
    this._startnim = function;
  }

  void capture({Offset offset}) async {
    if (_capture != null) {
      await _capture(offset: offset);
    }
  }

  void startAnim() {
    if (_startnim != null) {
      _startnim();
    }
  }
}

class ImagePainter extends CustomPainter {
  ui.Image image;

  Paint mainPaint;
  ImagePainter(this.image) {
    mainPaint = Paint()..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final List<RSTransform> transforms = <RSTransform>[
        RSTransform.fromComponents(
            rotation: 0, scale: size.height / image.height, anchorX: 0, anchorY: 0, translateX: 0, translateY: 0)
      ];
      canvas.drawAtlas(image, transforms, <Rect>[Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble())],
          <Color>[Colors.transparent], BlendMode.src, null, Paint());
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum ThemeChangeType { IDLE, CAPTURING, CAPTURE_FINISH, ANIMATING }
