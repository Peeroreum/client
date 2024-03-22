// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:peeroreum_client/designs/PeeroreumTypo.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class WhiteboardIedu extends StatefulWidget {
  const WhiteboardIedu({super.key});

  @override
  State<WhiteboardIedu> createState() => _WhiteboardIeduState();
}

class _WhiteboardIeduState extends State<WhiteboardIedu> {
  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _drawingController.setStyle(
        color: _straightColor, strokeWidth: _penStrokeWidth);
    super.initState();
  }

  longpressCheck() {
    if (isLongPressed[0]) {
      straightDetailTool();
      print(isLongPressed);
    } else if (isLongPressed[1]) {
      highlighterDetailTool();
    } else if (isLongPressed[2]) {
      eraserDetailTool();
    }
  }

  final DrawingController _drawingController = DrawingController();
  final WidgetsToImageController _imageController = WidgetsToImageController();
  Uint8List? bytes;
  XFile? whiteboardImage;

  List<bool> isPenSelected = [true, false, false];

  late Color _straightColor = straightColorSelect[0];
  List<bool> straightColorSelected = [true, false, false];
  List<Color> straightColorSelect = [
    PeeroreumColor.primaryPuple[400]!,
    PeeroreumColor.black,
    PeeroreumColor.white,
  ];

  late Color _highlighterColor = highlighterColorSelect[0];
  List<bool> highlighterColorSelected = [true, false, false];
  List<Color> highlighterColorSelect = [
    PeeroreumColor.primaryPuple[400]!,
    PeeroreumColor.black,
    PeeroreumColor.white,
  ];

  Color? _straightSavedColor;
  Color? _highlighterSavedColor;
  double _opacity = 1.0;
  double _penStrokeWidth = 1;
  double _highlighterStrokeWidth = 8;
  double _eraserStrokeWidth = 8;

  List<bool> isLongPressed = [false, false, false];

  List<bool> straightStroke = [true, false, false];
  List<bool> straightColor = [true, false, false];
  List<bool> highlighterStroke = [true, false, false];
  List<bool> highlighterColor = [true, false, false];
  List<bool> eraserStroke = [true, false, false];
  int redo = 0;
  int undo = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: PeeroreumColor.white,
          appBar: appbarWidget(),
          body: bodyWidget(),
        ),
      ),
    );
  }

  PreferredSizeWidget appbarWidget() {
    return AppBar(
      shape: Border(
        bottom: BorderSide(
          color: PeeroreumColor.gray[100]!,
          width: 1,
        ),
      ),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        color: PeeroreumColor.black,
        icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        onPressed: () async {
          if (undo > 0) {
            if (await onBackKey()) {
              Navigator.pop(context);
            }
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            if (undo > 0) postWhiteboard();
          },
          child: Container(
            margin: EdgeInsets.all(20),
            child: Text(
              '완료',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: undo > 0
                    ? PeeroreumColor.primaryPuple[400]
                    : PeeroreumColor.gray[500],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bodyWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return WidgetsToImage(
              controller: _imageController,
              child: DrawingBoard(
                onPointerUp: (pue) {
                  setState(() {
                    undo++;
                  });
                  print(undo);
                },
                controller: _drawingController,
                background: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: PeeroreumColor.white,
                ),
                boardBoundaryMargin: EdgeInsets.zero,
                showDefaultActions: false,
                showDefaultTools: false,
              ),
            );
          },
        ),
        bottomWidget(),
        if (isLongPressed[0])
          Positioned(
            bottom: 56,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 180, 0),
                child: straightDetailTool()),
          ),
        if (isLongPressed[1])
          Positioned(
            bottom: 56,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 180, 0),
                child: highlighterDetailTool()),
          ),
        if (isLongPressed[2])
          Positioned(
            bottom: 56,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 180, 0),
                child: eraserDetailTool()),
          ),
      ],
    );
  }

  Widget bottomWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.transparent,
          // padding: EdgeInsets.fromLTRB(34, 8, 34, 24),
          padding: EdgeInsets.only(bottom: 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: PeeroreumColor.gray[50],
              border: Border.all(
                color: PeeroreumColor.gray[100]!,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                penTool(),
                SizedBox(
                  width: 16,
                ),
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (undo > 0) {
                          _drawingController.undo();
                          setState(() {
                            undo--;
                            redo++;
                          });
                          print('redo: $redo');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/icons/arrow_bend_up_left.svg',
                          color: undo > 0
                              ? PeeroreumColor.gray[500]
                              : PeeroreumColor.gray[200],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (redo > 0) {
                          _drawingController.redo();
                          setState(() {
                            redo--;
                            undo++;
                          });
                          print('undo: $undo');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/icons/arrow_bend_up_right.svg',
                          color: redo > 0
                              ? PeeroreumColor.gray[500]
                              : PeeroreumColor.gray[200],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: 1,
                  height: 32,
                  color: PeeroreumColor.gray[100],
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _drawingController.clear();
                  },
                  child: T5_14px(
                    text: '모두 지우기',
                    color: PeeroreumColor.gray[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  penTool() {
    return SizedBox(
      height: 32,
      width: 112,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                isLongPressed = [false, false, false];
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 0;
                }
                _opacity = 1.0;
              });
              _drawingController.setPaintContent(SimpleLine());
              _drawingController.setStyle(
                  strokeWidth: _penStrokeWidth,
                  blendMode: BlendMode.srcOver,
                  color: _straightColor.withOpacity(_opacity));
            },
            onLongPress: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 0;
                }
                _opacity = 1.0;
                _drawingController.setPaintContent(SimpleLine());
                _drawingController.setStyle(
                    strokeWidth: _penStrokeWidth,
                    blendMode: BlendMode.srcOver,
                    color: _straightColor.withOpacity(_opacity));
                isLongPressed = [true, false, false];
                longpressCheck();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPenSelected[0]
                      ? PeeroreumColor.gray[200]
                      : PeeroreumColor.gray[50]),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                width: 24,
                child: SvgPicture.asset(
                  'assets/icons/pen_nib_straight.svg',
                  color: isPenSelected[0]
                      ? PeeroreumColor.black
                      : PeeroreumColor.gray[600],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                isLongPressed = [false, false, false];
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 1;
                }
                _opacity = 0.2;
              });
              _drawingController.setPaintContent(SimpleLine());
              _drawingController.setStyle(
                  strokeWidth: _highlighterStrokeWidth,
                  blendMode: BlendMode.srcOver,
                  color: _highlighterColor.withOpacity(_opacity));
            },
            onLongPress: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 1;
                }
                _opacity = 0.2;
                _drawingController.setPaintContent(SimpleLine());
                _drawingController.setStyle(
                    strokeWidth: _highlighterStrokeWidth,
                    blendMode: BlendMode.srcOver,
                    color: _highlighterColor.withOpacity(_opacity));
                isLongPressed = [false, true, false];
                longpressCheck();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPenSelected[1]
                      ? PeeroreumColor.gray[200]
                      : PeeroreumColor.gray[50]),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                width: 24,
                child: SvgPicture.asset(
                  'assets/icons/highlighter.svg',
                  color: isPenSelected[1]
                      ? PeeroreumColor.black
                      : PeeroreumColor.gray[600],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 2;
                }
                _opacity = 1.0;
              });
              _drawingController.setPaintContent(Eraser(color: Colors.white));
              _drawingController.setStyle(
                  strokeWidth: 20,
                  blendMode: BlendMode.srcOver,
                  color: Colors.white.withOpacity(1));
            },
            onLongPress: () {
              setState(() {
                for (int i = 0; i < isPenSelected.length; i++) {
                  isPenSelected[i] = i == 2;
                }
                _opacity = 1.0;
                _drawingController.setPaintContent(Eraser(color: Colors.white));
                _drawingController.setStyle(
                    strokeWidth: _eraserStrokeWidth,
                    blendMode: BlendMode.srcOver,
                    color: Colors.white.withOpacity(1));
                isLongPressed = [false, false, true];
                longpressCheck();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPenSelected[2]
                      ? PeeroreumColor.gray[200]
                      : PeeroreumColor.gray[50]),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                width: 24,
                child: SvgPicture.asset(
                  'assets/icons/eraser.svg',
                  color: isPenSelected[2]
                      ? PeeroreumColor.black
                      : PeeroreumColor.gray[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  straightDetailTool() {
    return Stack(
      children: [
        Image.asset('assets/images/background_straight.png'),
        Positioned(
          bottom: 44,
          left: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        straightStroke = [true, false, false];
                        _penStrokeWidth = 1;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _penStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _straightColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: straightStroke[0]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_1.svg',
                        color: straightStroke[0]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        straightStroke = [false, true, false];
                        _penStrokeWidth = 4;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _penStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _straightColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: straightStroke[1]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_2.svg',
                        color: straightStroke[1]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        straightStroke = [false, false, true];
                        _penStrokeWidth = 8;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _penStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _straightColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: straightStroke[2]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_3.svg',
                        color: straightStroke[2]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              straightColorTool(),
            ],
          ),
        ),
      ],
    );
  }

  highlighterDetailTool() {
    return Stack(
      children: [
        Image.asset('assets/images/background_highlighter.png'),
        Positioned(
          bottom: 44,
          left: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        highlighterStroke = [true, false, false];
                        _highlighterStrokeWidth = 10;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _highlighterStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _highlighterColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: highlighterStroke[0]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_1.svg',
                        color: highlighterStroke[0]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        highlighterStroke = [false, true, false];
                        _highlighterStrokeWidth = 20;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _highlighterStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _highlighterColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: highlighterStroke[1]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_2.svg',
                        color: highlighterStroke[1]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        highlighterStroke = [false, false, true];
                        _highlighterStrokeWidth = 30;
                      });
                      _drawingController.setStyle(
                          strokeWidth: _highlighterStrokeWidth,
                          blendMode: BlendMode.srcOver,
                          color: _highlighterColor.withOpacity(_opacity));
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: highlighterStroke[2]
                              ? PeeroreumColor.gray[200]
                              : PeeroreumColor.gray[50]),
                      child: SvgPicture.asset(
                        'assets/images/straight_3.svg',
                        color: highlighterStroke[2]
                            ? PeeroreumColor.black
                            : PeeroreumColor.gray[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              highlighterColorTool(),
            ],
          ),
        ),
      ],
    );
  }

  eraserDetailTool() {
    return Stack(
      children: [
        Image.asset('assets/images/background_eraser.png'),
        Positioned(
          bottom: 44,
          left: 20,
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    eraserStroke = [true, false, false];
                    _eraserStrokeWidth = 8;
                  });
                  _drawingController.setStyle(
                      strokeWidth: _eraserStrokeWidth,
                      blendMode: BlendMode.srcOver,
                      color: _straightColor.withOpacity(_opacity));
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: eraserStroke[0]
                          ? PeeroreumColor.gray[200]
                          : PeeroreumColor.gray[50]),
                  child: SvgPicture.asset(
                    'assets/images/straight_1.svg',
                    color: eraserStroke[0]
                        ? PeeroreumColor.black
                        : PeeroreumColor.gray[600],
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    eraserStroke = [false, true, false];
                    _eraserStrokeWidth = 20;
                  });
                  _drawingController.setStyle(
                      strokeWidth: _eraserStrokeWidth,
                      blendMode: BlendMode.srcOver,
                      color: _straightColor.withOpacity(_opacity));
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: eraserStroke[1]
                          ? PeeroreumColor.gray[200]
                          : PeeroreumColor.gray[50]),
                  child: SvgPicture.asset(
                    'assets/images/straight_2.svg',
                    color: eraserStroke[1]
                        ? PeeroreumColor.black
                        : PeeroreumColor.gray[600],
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    eraserStroke = [false, false, true];
                    _eraserStrokeWidth = 30;
                  });
                  _drawingController.setStyle(
                      strokeWidth: _eraserStrokeWidth,
                      blendMode: BlendMode.srcOver,
                      color: _straightColor.withOpacity(_opacity));
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: eraserStroke[2]
                          ? PeeroreumColor.gray[200]
                          : PeeroreumColor.gray[50]),
                  child: SvgPicture.asset(
                    'assets/images/straight_3.svg',
                    color: eraserStroke[2]
                        ? PeeroreumColor.black
                        : PeeroreumColor.gray[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  straightColorTool() {
    return SizedBox(
      height: 32,
      width: 112,
      child: Column(
        children: [
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < straightColorSelected.length; i++) {
                        straightColorSelected[i] = i == index;
                      }
                      switch (index) {
                        case 0:
                          _straightColor = straightColorSelect[0];
                          _drawingController.setStyle(
                              color:
                                  straightColorSelect[0].withOpacity(_opacity));
                          _straightSavedColor = null;
                          break;
                        case 1:
                          _straightColor = straightColorSelect[1];
                          _drawingController.setStyle(
                              color:
                                  straightColorSelect[1].withOpacity(_opacity));
                          _straightSavedColor = null;
                          break;
                      }
                      if (index == 2) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: PeeroreumColor.white,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ColorPicker(
                                        pickerAreaHeightPercent: 0.7,
                                        pickerAreaBorderRadius:
                                            BorderRadius.circular(10),
                                        showLabel: false,
                                        enableAlpha: false,
                                        pickerColor: _straightColor,
                                        onColorChanged: (Color color) {
                                          setState(() {
                                            _straightSavedColor = color;
                                          });
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '취소',
                                              style: TextStyle(
                                                  color:
                                                      PeeroreumColor.gray[600],
                                                  fontFamily: 'Pretendard'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _straightColor =
                                                    _straightSavedColor!;
                                                _drawingController.setStyle(
                                                    color: _straightColor
                                                        .withOpacity(_opacity));
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                  color: PeeroreumColor
                                                      .primaryPuple[400],
                                                  fontFamily: 'Pretendard'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            );
                          },
                        );
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index != 2
                          ? straightColorSelect[index]
                          : _straightColor,
                      border: Border.all(
                        color: PeeroreumColor.gray[100]!,
                        width: 2,
                      ),
                      image: index == 2
                          ? _straightSavedColor != _straightColor
                              ? DecorationImage(
                                  image: AssetImage(
                                      'assets/images/colorpicker_background.png'),
                                )
                              : null
                          : null,
                    ),
                    child: index == 2
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.asset(
                              'assets/icons/spoid.svg',
                              color: PeeroreumColor.white,
                            ))
                        : straightColorSelected[index]
                            ? Padding(
                                padding: EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/icons/check2.svg',
                                  color: PeeroreumColor.white,
                                ),
                              )
                            : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  highlighterColorTool() {
    return SizedBox(
      height: 32,
      width: 112,
      child: Column(
        children: [
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (int i = 0;
                          i < highlighterColorSelected.length;
                          i++) {
                        highlighterColorSelected[i] = i == index;
                      }
                      switch (index) {
                        case 0:
                          _highlighterColor = highlighterColorSelect[0];
                          _drawingController.setStyle(
                              color: highlighterColorSelect[0]
                                  .withOpacity(_opacity));
                          _highlighterSavedColor = null;
                          break;
                        case 1:
                          _highlighterColor = highlighterColorSelect[1];
                          _drawingController.setStyle(
                              color: highlighterColorSelect[1]
                                  .withOpacity(_opacity));
                          _highlighterSavedColor = null;
                          break;
                      }
                      if (index == 2) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: PeeroreumColor.white,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ColorPicker(
                                        pickerAreaHeightPercent: 0.7,
                                        pickerAreaBorderRadius:
                                            BorderRadius.circular(10),
                                        showLabel: false,
                                        enableAlpha: false,
                                        pickerColor: _highlighterColor,
                                        onColorChanged: (Color color) {
                                          setState(() {
                                            _highlighterSavedColor = color;
                                          });
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '취소',
                                              style: TextStyle(
                                                  color:
                                                      PeeroreumColor.gray[600],
                                                  fontFamily: 'Pretendard'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _highlighterColor =
                                                    _highlighterSavedColor!;
                                                _drawingController.setStyle(
                                                    color: _highlighterColor
                                                        .withOpacity(_opacity));
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                  color: PeeroreumColor
                                                      .primaryPuple[400],
                                                  fontFamily: 'Pretendard'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            );
                          },
                        );
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index != 2
                          ? highlighterColorSelect[index]
                          : _highlighterColor,
                      border: Border.all(
                        color: PeeroreumColor.gray[100]!,
                        width: 2,
                      ),
                      image: index == 2
                          ? _highlighterSavedColor != _highlighterColor
                              ? DecorationImage(
                                  image: AssetImage(
                                      'assets/images/colorpicker_background.png'),
                                )
                              : null
                          : null,
                    ),
                    child: index == 2
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.asset(
                              'assets/icons/spoid.svg',
                              color: PeeroreumColor.white,
                            ))
                        : highlighterColorSelected[index]
                            ? Padding(
                                padding: EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/icons/check2.svg',
                                  color: PeeroreumColor.white,
                                ),
                              )
                            : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  postWhiteboard() async {
    bytes = await _imageController.capture();

    Directory? tempDir = await getTemporaryDirectory();
    File? file = File(
        '${tempDir.path}/whiteboard${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes!);
    whiteboardImage = (XFile(file.path));

    if (mounted) {
      Navigator.pop(context, whiteboardImage);
    }
  }

  Future<bool> onBackKey() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: PeeroreumColor.white,
          surfaceTintColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "이 화면을 나가시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "작성하신 내용이 삭제됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PeeroreumColor.gray[600],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.gray[300], // 배경 색상
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16), // 패딩
                          shape: RoundedRectangleBorder(
                            // 모양
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.gray[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PeeroreumColor.primaryPuple[400],
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '나가기',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: PeeroreumColor.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
