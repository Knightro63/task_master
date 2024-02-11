import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final double physicalHeight =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
final double phyiscalWidth =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
final double devicePixelRatio =
    WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

double deviceWidth = phyiscalWidth / devicePixelRatio;
double deviceHeight = physicalHeight / devicePixelRatio;
double widthInifity = double.infinity;

/// Removes Null values from the parameter passed
dynamic removeNull(dynamic params) {
  if (params is Map) {
    Map<dynamic, dynamic> map = {};
    params.forEach((key, val) {
      dynamic value = removeNull(val);
      if (value != null) {
        map[key] = value;
      }
    });

    if (map.isNotEmpty) {
      return map;
    }
  } 
  else if (params is List) {
    List list = [];
    for (var val in params) {
      dynamic value = removeNull(val);
      if (value != null) {
        list.add(value);
      }
    }

    if (list.isNotEmpty) {
      return list;
    }
  } 
  else if (params != null) {
    return params;
  }
  return null;
}

Color responsiveColor(Color color, [double amount = .1]) {
  if (amount > 1) {
    amount = 1;
  } else if (amount < 0) {
    amount = 0;
  }

  return color.computeLuminance() > 0.5
      ? darken(color, amount)
      : lighten(color, amount);
}

/// Returns darker version of color passesd
Color darken(Color color, [double amount = .1]) {
  if (amount > 1) {
    amount = 1;
  } else if (amount < 0) {
    amount = 0;
  }

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

double responsive({double? width, double smallest = 650, int total = 1}) {
  width = width ?? widthInifity;
  if (width < smallest) {
    return width / total - 20;
  } else if (width < smallest + 350) {
    return width / (2 + (total - 1)) - 20;
  } else {
    return width / (3 + (total - 1)) - 20;
  }
}

/// Returns lighter version of color passed
Color lighten(Color color, [double amount = .1]) {
  if (amount > 1) {
    amount = 1;
  } else if (amount < 0) {
    amount = 0;
  }

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

/// Custom-made button used in the package
Widget squareButton({
  Key? key,
  bool iconFront = false,
  Widget? icon,
  Color buttonColor = const Color(0xFF06A7E2),
  Color textColor = const Color(0xff989898),
  required String text,
  Function()? onTap,
  String fontFamily = 'Klavika Bold',
  double fontSize = 15.0,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  double height = 75,
  double width = 100,
  double radius = 5,
  Alignment? alignment,
  EdgeInsets? margin,
  EdgeInsets? padding,
  List<BoxShadow>? boxShadow,
  Color? borderColor,
  bool loading = false,
  Function(PointerEnterEvent)? onHoverEnter,
  Function(PointerExitEvent)? onHoverExit,
}) {
  Widget totalIcon = (icon != null) ? icon : Container();
  return MouseRegion(
      onEnter: onHoverEnter,
      onExit: onHoverExit,
      child: InkWell(
          onTap: onTap,
          child: Container(
              alignment: alignment,
              height: height,
              width: width,
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                  color: buttonColor,
                  border: Border.all(
                      color: (borderColor == null) ? buttonColor : borderColor,
                      width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  boxShadow: boxShadow),
              child: loading
                  ? LoadingWheel(
                      color: buttonColor,
                      indicatorColor: textColor,
                    )
                  : Row(
                      key: key,
                      mainAxisAlignment: mainAxisAlignment,
                      children: [
                        (iconFront) ? totalIcon : Container(),
                        Text(text.toUpperCase(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: textColor,
                                fontSize: fontSize,
                                fontFamily: fontFamily,
                                decoration: TextDecoration.none)),
                        (!iconFront) ? totalIcon : Container(),
                      ],
                    ))));
}

/// Custom loading wheel animation used in the package
class LoadingWheel extends StatelessWidget {
  LoadingWheel({Key? key, this.color, this.indicatorColor}) : super(key: key);
  final double size =
      (deviceWidth < deviceHeight) ? deviceWidth / 4 : deviceHeight / 4;
  final Color? color;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: deviceWidth,
        height: deviceHeight,
        color: color ?? Theme.of(context).canvasColor,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: indicatorColor));
  }
}

/// Custom action button used in the package
class TaskMasterFloatingActionButton extends StatelessWidget {
  TaskMasterFloatingActionButton({
    GlobalKey? key,
    required this.allowed,
    this.onTap,
    this.color = const Color(0xFF06A7E2),
    required this.icon,
    this.size = 60,
    this.iconSize = 35,
    this.offset = const Offset(20, 20),
    this.margin = const EdgeInsets.only(bottom: 50, right: 20),
    this.iconColor = Colors.white,
    this.onHoverEnter,
    this.onHoverExit,
    this.alignment = Alignment.bottomRight
  }): super(key: key) {
    if (alignment == Alignment.bottomRight) {
      bottom = offset.dy;
      right = offset.dx;

      left = null;
      top = null;
    } else if (alignment == Alignment.bottomLeft) {
      bottom = offset.dy;
      left = offset.dx;

      right = null;
      top = null;
    } else if (alignment == Alignment.topRight) {
      top = offset.dy;
      right = offset.dx;

      bottom = null;
      left = null;
    } else if (alignment == Alignment.topLeft) {
      top = offset.dy;
      left = offset.dx;

      bottom = null;
      right = null;
    }
  }

  late final double? left;
  late final double? top; 
  late final double? right;
  late final double? bottom;
  final bool allowed;
  final Function()? onTap;
  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;
  final Offset offset;
  final EdgeInsets margin;
  final Color iconColor;
  final Function(PointerEvent)? onHoverEnter;
  final Function(PointerEvent)? onHoverExit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return (allowed)
        ? Positioned(
            key: key,
            left: left,
            top: top,
            bottom: bottom,
            right: right,
            child: MouseRegion(
                onEnter: onHoverEnter,
                onExit: onHoverExit,
                child: InkWell(
                    onTap: onTap,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.all(Radius.circular(size / 2)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                      ),
                    ))))
        : Container();
  }
}

class SingleUserIcon extends StatelessWidget {
  const SingleUserIcon(
      {Key? key,
      required this.uid,
      required this.color,
      this.usersProfile,
      this.iconSize = 40,
      this.remove,
      required this.loc})
      : super(key: key);

  final String uid;
  final Color color;
  final int loc;
  final double iconSize;
  final Function(int loc)? remove;
  final dynamic usersProfile;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      (usersProfile != null &&
              usersProfile[uid] != null &&
              usersProfile[uid]['imageUrl'] != '')
          ? Container(
              width: iconSize,
              height: iconSize,
              margin: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(40 / 2)),
                  border: Border.all(color: color, width: 3),
                  image: DecorationImage(
                    image: NetworkImage(usersProfile[uid]['imageUrl']),
                  )))
          : Container(
              alignment: Alignment.center,
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(40 / 2)),
                  border: Border.all(color: color, width: 5)),
              child: Text(
                usersProfile[uid]['displayName'][0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    fontSize: 20),
              ),
            ),
      remove != null
          ? Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () => remove!(loc),
                child: Container(
                  width: 15,
                  height: 15,
                  margin: const EdgeInsets.only(left: 5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(15 / 2)),
                  ),
                  child: const Icon(
                    Icons.remove_circle,
                    size: 12,
                  ),
                ),
              ))
          : Container()
    ]);
  }
}

class UserIcon extends StatelessWidget {
  const UserIcon({
    Key? key,
    required this.uids,
    required this.colors,
    this.remove,
    this.usersProfile,
    this.iconSize = 40,
    required this.viewidth,
  }) : super(key: key);

  final List<String> uids;
  final List<Color> colors;
  final double iconSize;
  final double viewidth;
  final Function(int loc)? remove;
  final dynamic usersProfile;

  @override
  Widget build(BuildContext context) {
    List<Widget> char = [];
    if (uids.isNotEmpty) {
      for (int i = 0; i < uids.length; i++) {
        char.add(SingleUserIcon(
          uid: uids[i],
          color: i % 2 == 0 ? colors[0] : colors[1],
          loc: i,
          remove: remove,
          iconSize: iconSize,
          usersProfile: usersProfile,
        ));
      }
    }

    if (char.isEmpty) {
      char.add(Container());
    }
    return SizedBox(
        width: viewidth,
        height: iconSize,
        child: ListView(scrollDirection: Axis.horizontal, children: char));
  }
}

/// Use to display info on the epic and project at the top of the page
class TopInfo extends StatelessWidget {
  const TopInfo(
      {Key? key,
      required this.title,
      this.info = '',
      this.titleWidget,
      this.width,
      this.onTap,
      this.wrap = true,
      this.backButton = false,
      this.useShaddow = true})
      : super(key: key);
  final Function()? onTap;
  final bool backButton;
  final String title;
  final String info;
  final Widget? titleWidget;
  final double? width;
  final bool useShaddow;
  final bool wrap;

  double responsive2({double width = 0}) {
    width = (width != 0) ? width : widthInifity;
    if (width < 1000) {
      return width - 40;
    } else if (width < 1363) {
      return width - (40 + width / 1363 * 320);
    } else {
      return width - 360;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      (backButton)
          ? InkWell(
              onTap: onTap,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            )
          : Container(),
      Text('$title:  ', style: Theme.of(context).primaryTextTheme.headlineMedium),
      (titleWidget != null) ? titleWidget! : Container()
    ];
    return Container(
        width: (width == null) ? deviceWidth : width,
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
        decoration: (useShaddow)
            ? BoxDecoration(
                color: Theme.of(context).indicatorColor,
                boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ])
            : BoxDecoration(
                color: Theme.of(context).indicatorColor,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wrap
                ? Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: children)
                : Row(
                    children: children,
                  ),
            (info != '')
                ? Column(children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: responsive2(),
                      child: Text(info,
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).primaryTextTheme.bodySmall),
                    ),
                    const SizedBox(height: 10)
                  ])
                : Container(),
          ],
        ));
  }
}
