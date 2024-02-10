import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../task_master.dart';
import '../task_widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../util/textformfield.dart';

class ProjectManager extends StatefulWidget {
  const ProjectManager({
    Key? key,
    this.onSubmit,
    this.onComplete,
    this.onTitleChange,
    this.onFocusNode,
    required this.projectData,
    this.onProjectTap,
    this.onProjectDelete,
    this.onUpdate,
    this.onLabelsAdded,
    this.width = 320,
    this.height = 360,
    this.cardWidth = 300,
    required this.allowEditing,
    required this.epic,
    this.startProject,
    this.onSubmitLabel,
    this.onUpdateLabel,
    this.onDeleteLabel,
    this.labels
  }):super(key: key);

  /// Callback for project creation/submit
  final Function(String title, String image, String date, int color)? onSubmit;

  /// Callback for project updates
  final Function(String title, String image, String date, int color,
      String selectedProject)? onUpdate;

  /// Callback for project completion
  final Function(String selectedProject)? onComplete;

  final Function? onFocusNode;

  /// Callback for project deletion
  final Function(String id)? onProjectDelete;

  /// Callback for project title changes
  final Function(String id, String title)? onTitleChange;

  final List<ProjectData> projectData;

  /// Callback for tapping on project
  final Function(String projectName)? onProjectTap;

  final double? height;
  final double? width;

  /// Determine if current user is allowed to edit
  final bool allowEditing;

  /// Sets width of cards
  final double cardWidth;

  /// Epic that encompasses all the projects to be managed
  final String epic;

  /// Project that is selected by default
  final String? startProject;

  /// Callback to define behavior for adding new labels
  final Function? onLabelsAdded;

  /// Callback function to define behavior for label submission
  final Function(dynamic data)? onSubmitLabel;

  /// Callback function to define behavior for label updates
  final Function(dynamic data, String location)? onUpdateLabel;

  /// Callback function to define behavior for label submission
  final Function(String selectedLabel)? onDeleteLabel;

  /// Holds the InkWells of the various labels
  final dynamic labels;

  @override
  _ProjectManagerState createState() => _ProjectManagerState();
}

class _ProjectManagerState extends State<ProjectManager> {
  String assignedDate = '';
  String selectedProject = '';
  String editProject = '';
  DateTime selectedDate = DateTime.now();

  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectImageController = TextEditingController();
  List<TextEditingController> nameChangeController = [];
  bool error = false;
  bool isNewProject = true;
  Color projectClickedColor = Colors.white;
  List<Color> hexColors = [
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.lightBlue,
    Colors.blue,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey
  ];
  List<IconData> cbIcon = [
    Icons.ac_unit,
    Icons.gavel,
    Icons.extension,
    Icons.settings_input_antenna,
    Icons.settings_input_component,
    Icons.polymer,
    Icons.code_off,
    Icons.insights,
    Icons.stream,
    Icons.gesture,
    Icons.grain,
    Icons.texture,
    Icons.dialpad,
    Icons.bubble_chart
  ];

  TextEditingController labelNameController = TextEditingController();
  bool isNewLabel = true;
  String selectedLabel = '';

  late String epic;

  dynamic labelData;

  @override
  void initState() {
    start();
    super.initState();
  }

  void start() {
    epic = widget.epic;
    selectedProject = widget.startProject ?? '';
    labelData = widget.labels;
  }

  void reset() {
    setState(() {});
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  // Sets up data to be displayed in update dialog for a project
  void setUpdateData(int i) {
    projectClickedColor = Colors.white;
    setState(() {
      isNewProject = false;
      projectNameController.text = widget.projectData[i].title;
      selectedDate = (widget.projectData[i].dueDate != null)
          ? DateTime.parse(widget.projectData[i].dueDate!.replaceAll('T', ' '))
          : DateTime.now();
      assignedDate = (widget.projectData[i].dueDate != null)
          ? widget.projectData[i].dueDate!.split('T')[0]
          : '';
      projectClickedColor = Color(widget.projectData[i].color);
    });
  }

  // Displays Created By, Creation date and due date of projects
  Widget info(ProjectData data, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          children: [
            Row(children: [
              Text(
                'Created By: ',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    fontSize: 14),
              ),
              Text(
                data.createdBy,
                style: TextStyle(
                    color: color,
                    fontFamily: 'Klavika',
                    package: 'css',
                    fontSize: 14),
              )
            ]),
            Row(children: [
              Text(
                'Date Created: ',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    fontSize: 14),
              ),
              Text(
                data.dateCreated.split('T')[0],
                style: TextStyle(
                    color: color,
                    fontFamily: 'Klavika',
                    package: 'css',
                    fontSize: 14),
              )
            ]),
            (data.dueDate != null)
                ? Row(children: [
                    Text(
                      'Due Date: ',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .subtitle1!
                              .color,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          fontSize: 14),
                    ),
                    Text(
                      data.dueDate!.split('T')[0],
                      style: TextStyle(
                          color: color,
                          fontFamily: 'Klavika',
                          package: 'css',
                          fontSize: 14),
                    )
                  ])
                : Container(height: 16),
          ],
        )
      ]),
    );
  }

  // Displays the project name
  Widget title(String title, String subtitle, Color color) {
    return Container(
      width: widget.cardWidth,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: widget.cardWidth,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10, top: 15),
                padding: const EdgeInsets.only(left: 10),
                color: Theme.of(context).splashColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subtitle,
                        style: TextStyle(
                            color: color,
                            fontFamily: Theme.of(context)
                                .primaryTextTheme
                                .bodyText2!
                                .fontFamily,
                            decoration: TextDecoration.none)),
                    InkWell(
                      onTap: () {
                        if (widget.onProjectDelete != null &&
                            widget.allowEditing) {
                          widget.onProjectDelete!(title);
                        }
                      },
                      child: Icon(
                        Icons.delete_forever,
                        size: 20,
                        color:
                            Theme.of(context).primaryTextTheme.bodyText2!.color,
                      ),
                    )
                  ],
                )),
          ]),
    );
  }

  // Function that builds list of projectCard widgets
  List<Widget> projectCards() {
    List<Widget> projects = [];
    int numOfPro = widget.projectData.length;
    for (int i = 0; i < numOfPro; i++) {
      projects.add(InkWell(
        onLongPress: () {
          editProject = widget.projectData[i].id;
          setUpdateData(i);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return projectName();
              });
        },
        onDoubleTap: () {
          editProject = widget.projectData[i].id;
          setUpdateData(i);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return projectName();
              });
        },
        onTap: () {
          if (widget.onProjectTap != null) {
            widget.onProjectTap!(widget.projectData[i].id);
          }
          setState(() {
            selectedProject = widget.projectData[i].id;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 20, right: 5, left: 5),
          width: widget.cardWidth,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Theme.of(context).cardColor,
              border: Border.all(
                width: 2,
                color: (selectedProject == widget.projectData[i].id)
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).cardColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]),
          child: Column(
            children: [
              title(widget.projectData[i].id, widget.projectData[i].title,
                  Color(widget.projectData[i].color)),
              info(widget.projectData[i], Color(widget.projectData[i].color))
            ],
          ),
        ),
      ));
    }
    if (numOfPro > 0) {
      int allowed = (widget.width! / (widget.cardWidth)).floor();
      int leftOver = numOfPro - (numOfPro ~/ allowed) * allowed + 1;
      for (int i = 0; i < leftOver; i++) {
        projects.add(SizedBox(
          width: widget.cardWidth,
          height: 265 / 2,
        ));
      }
    }

    return projects;
  }

  /// Creates Color Indicators to select colors for customization
  Widget createColorIndicators(void Function() callback) {
    List<Widget> colorsWidget = [];
    for (int i = 0; i < hexColors.length - 1; i++) {
      colorsWidget.add(InkWell(
        onTap: () {
          projectClickedColor = hexColors[i];
          callback();
        },
        child: Container(
          height: 320 / hexColors.length,
          width: 320 / hexColors.length,
          decoration: BoxDecoration(
              color: hexColors[i],
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: (projectClickedColor.value == hexColors[i].value)
              ? Icon(Icons.check,
                  size: 320 / hexColors.length, color: Colors.white)
              : Container(),
        ),
      ));
    }
    colorsWidget.add(InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Pick a color!'),
                content: SizedBox(
                  width: 250,
                  height: 260,
                  child: ColorPicker(
                    pickerColor: projectClickedColor,
                    onColorChanged: (color) {
                      setState(() {
                        projectClickedColor = color;
                      });
                    },
                    colorPickerWidth: 250,
                    pickerAreaHeightPercent: 0.7,
                    portraitOnly: true,
                    enableAlpha: false,
                    labelTypes: [],
                    pickerAreaBorderRadius: BorderRadius.circular(10),
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Got it'),
                    onPressed: () {
                      callback();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }).then((value) {
          callback();
        });
        callback();
      },
      child: Container(
        height: 320 / hexColors.length,
        width: 320 / hexColors.length,
        decoration: BoxDecoration(
            color: projectClickedColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Icon(Icons.color_lens,
            size: 320 / hexColors.length,
            color: responsiveColor(projectClickedColor, 0.5)),
      ),
    ));
    return Wrap(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: colorsWidget);
  }

  // Widget for project creation/editing dialog
  Widget projectName() {
    return StatefulBuilder(builder: (context, setState) {
      // Creates handles the date picker for the project due date
      void _selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.isBefore(DateTime.now())
              ? DateTime.now()
              : selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            var formatter = DateFormat('y-MM-dd');
            assignedDate = formatter.format(picked);
            selectedDate = picked;
          });
        }
      }

      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 380,
            width: responsive(),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Please Enter the name of the story!",
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText2!.color,
                        fontFamily: 'Klavika',
                        package: 'css',
                        fontSize: 20),
                  ),
                  Wrap(
                    children: [
                      Text(
                        "Name: ",
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyText2!
                                .color,
                            fontFamily: 'Klavika',
                            package: 'css',
                            fontSize: 20),
                      ),
                      EnterTextFormField(
                        width: responsive() - 120,
                        height: 35,
                        color: Theme.of(context).canvasColor,
                        maxLines: 1,
                        label: 'Project Name',
                        controller: projectNameController,
                        onTap: () {
                          if (widget.onFocusNode != null) {
                            widget.onFocusNode!();
                          }
                        },
                      )
                    ],
                  ),
                  createColorIndicators(() {
                    setState(() {});
                  }),
                  Row(
                    children: [
                      TaskWidgets.iconNote(
                          Icons.insert_invitation_outlined,
                          "Due Date: ",
                          TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText2!
                                  .color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none),
                          20),
                      InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: SizedBox(
                            child: Text(
                              (assignedDate == '')
                                  ? DateFormat('y-MM-dd').format(DateTime.now())
                                  : assignedDate,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText2!
                                      .color,
                                  fontFamily: 'Klavika',
                                  package: 'css',
                                  fontSize: 20,
                                  decoration: TextDecoration.none),
                            ),
                          ))
                    ],
                  ),
                  (error)
                      ? const Text(
                          "Field is missing Data!",
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20),
                        )
                      : Container(),
                  Wrap(
                      runSpacing: 20,
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        squareButton(
                          text: 'cancel',
                          onTap: () {
                            setState(() {
                              projectNameController.text = '';
                            });
                            projectClickedColor = Colors.white;
                            error = false;
                            Navigator.of(context).pop();
                          },
                          buttonColor: Colors.transparent,
                          borderColor: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2!
                              .color,
                          height: 45,
                          radius: 45 / 2,
                          width: 320 / 3 - 10,
                        ),
                        (!isNewProject)
                            ? squareButton(
                                text: 'complete',
                                onTap: () {
                                  if (widget.onComplete != null) {
                                    widget.onComplete!(editProject);
                                  }
                                  setState(() {
                                    error = false;
                                    projectNameController.text = '';
                                  });
                                  projectClickedColor = Colors.white;
                                  Navigator.of(context).pop();
                                },
                                textColor: Theme.of(context).indicatorColor,
                                buttonColor: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText2!
                                    .color!,
                                height: 45,
                                radius: 45 / 2,
                                width: 320 / 3 - 10,
                              )
                            : Container(),
                        squareButton(
                          text: (isNewProject) ? 'submit' : 'update',
                          onTap: () {
                            if (projectNameController.text != '') {
                              if (isNewProject) {
                                if (widget.onSubmit != null) {
                                  widget.onSubmit!(
                                      projectNameController.text,
                                      projectImageController.text,
                                      (assignedDate != '')
                                          ? selectedDate
                                              .toString()
                                              .replaceAll(' ', 'T')
                                          : '',
                                      projectClickedColor.value);
                                }
                              } else {
                                if (widget.onUpdate != null) {
                                  widget.onUpdate!(
                                      projectNameController.text,
                                      projectImageController.text,
                                      (assignedDate != '')
                                          ? selectedDate
                                              .toString()
                                              .replaceAll(' ', 'T')
                                          : '',
                                      projectClickedColor.value,
                                      editProject);
                                }
                              }
                              setState(() {
                                error = false;
                                projectNameController.text = '';
                              });
                              projectClickedColor = Colors.white;
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                error = true;
                              });
                            }
                          },
                          textColor: Theme.of(context).indicatorColor,
                          buttonColor: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2!
                              .color!,
                          height: 45,
                          radius: 45 / 2,
                          width: 320 / 3 - 10,
                        )
                      ])
                ]),
          ));
    });
  }

  /// Widget for label creation/editing dialog
  Widget createLabel() {
    return StatefulBuilder(builder: (context, setState) {
      List<Widget> allLabels() {
        List<Widget> labels = [];
        if (labelData != null) {
          for (String key in labelData.keys) {
            if (labelData[key] == null) continue;
            labels.add(InkWell(
                onTap: () {
                  setState(() {
                    isNewLabel = false;
                    labelNameController.text = labelData[key]['name'];
                    selectedLabel = key;
                    projectClickedColor = Color(labelData[key]['color']);
                  });
                },
                child: Container(
                  height: 30,
                  width: responsive() - 30,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(labelData[key]['color']),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    labelData[key]['name'].toUpperCase(),
                    style: TextStyle(
                        fontFamily: 'Klavika',
                        package: 'css',
                        fontSize: 24,
                        color: Theme.of(context)
                            .primaryTextTheme
                            .subtitle2!
                            .color),
                  ),
                )));
          }
        } else {
          labels.add(Container());
        }

        return labels;
      }

      int hmLabels = 0;
      if (labelData != null) {
        hmLabels = labelData.length;
      }
      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
              height: (hmLabels * 35.0 > deviceHeight - 50)
                  ? deviceHeight - 50
                  : hmLabels * 35.0 + 260,
              width: responsive() + 20,
              alignment: Alignment.center,
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: (hmLabels * 35.0 > deviceHeight - 50)
                        ? deviceHeight - 50
                        : hmLabels * 35.0 + 260,
                    width: responsive(),
                    //alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ]),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              height: (hmLabels * 35.0 > deviceHeight - 260)
                                  ? deviceHeight - 260.0
                                  : hmLabels * 35.0,
                              width: responsive() - 20,
                              child: ListView(
                                  padding: const EdgeInsets.all(0),
                                  children: allLabels())),
                          Container(
                            width: deviceWidth,
                            height: 2,
                            color: Theme.of(context).canvasColor,
                          ),
                          Wrap(
                            children: [
                              Text(
                                "Name:",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText2!
                                        .color,
                                    fontFamily: 'Klavika',
                                    package: 'css',
                                    fontSize: 20),
                              ),
                              EnterTextFormField(
                                width: responsive() - 120,
                                height: 35,
                                color: Theme.of(context).canvasColor,
                                maxLines: 1,
                                label: 'Label Name',
                                controller: labelNameController,
                                onEditingComplete: () {},
                                onSubmitted: (val) {},
                                onTap: () {
                                  if (widget.onFocusNode != null) {
                                    widget.onFocusNode!();
                                  }
                                },
                              )
                            ],
                          ),
                          createColorIndicators(() {
                            setState(() {});
                          }),
                          (error)
                              ? const Text(
                                  "Field is missing Data!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'Klavika',
                                      package: 'css',
                                      fontSize: 20),
                                )
                              : Container(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                squareButton(
                                  text: 'cancel',
                                  onTap: () {
                                    setState(() {
                                      labelNameController.text = '';
                                    });
                                    projectClickedColor = Colors.white;
                                    selectedLabel = '';
                                    isNewLabel = true;
                                    error = false;
                                    Navigator.of(context).pop();
                                  },
                                  buttonColor: Colors.transparent,
                                  borderColor: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText2!
                                      .color,
                                  height: 45,
                                  radius: 45 / 2,
                                  width: 320 / 2,
                                ),
                                (isNewLabel)
                                    ? Container()
                                    : squareButton(
                                        text: 'delete',
                                        onTap: () {
                                          if (widget.onDeleteLabel != null)
                                            widget
                                                .onDeleteLabel!(selectedLabel);

                                          setState(() {
                                            labelNameController.text = '';
                                          });

                                          isNewLabel = true;
                                          selectedLabel = '';
                                          projectClickedColor = Colors.white;
                                        },
                                        textColor:
                                            Theme.of(context).indicatorColor,
                                        buttonColor: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2!
                                            .color!,
                                        height: 45,
                                        radius: 45 / 2,
                                        width: 320 / 2,
                                      ),
                                squareButton(
                                  text: (isNewLabel) ? 'submit' : 'update',
                                  onTap: () {
                                    if (labelNameController.text != '') {
                                      if (isNewLabel) {
                                        widget.onSubmitLabel!({
                                          'name': labelNameController.text,
                                          'color': projectClickedColor.value
                                        });
                                        if (widget.onLabelsAdded != null) {
                                          widget.onLabelsAdded!();
                                        }
                                      } else {
                                        widget.onUpdateLabel!({
                                          'name': labelNameController.text,
                                          'color': projectClickedColor.value
                                        }, selectedLabel);
                                        if (widget.onLabelsAdded != null) {
                                          widget.onLabelsAdded!();
                                        }
                                      }

                                      setState(() {
                                        error = false;
                                        labelNameController.text = '';
                                      });
                                      isNewLabel = true;
                                      selectedLabel = '';
                                      projectClickedColor = Colors.white;
                                    } else {
                                      setState(() {
                                        error = true;
                                      });
                                    }
                                  },
                                  textColor: Theme.of(context).indicatorColor,
                                  buttonColor: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText2!
                                      .color!,
                                  height: 45,
                                  radius: 45 / 2,
                                  width: 320 / 2,
                                ),
                              ])
                        ]),
                  )
                ],
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.epic != epic) {
        setState(() {
          start();
        });
      }
      if (widget.labels != labelData) {
        setState(() {
          start();
        });
      }
    });
    double width = (widget.width == null)
        ? MediaQuery.of(context).size.width
        : widget.width!;
    return InkWell(
        mouseCursor: MouseCursor.defer,
        onTap: () {
          setState(() {
            FocusManager.instance.primaryFocus?.unfocus();
          });
        },
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          (widget.projectData.isNotEmpty)
              ? Container(
                  height: (widget.height == null)
                      ? MediaQuery.of(context).size.height
                      : widget.height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                  child: ListView(padding: const EdgeInsets.all(0), children: [
                    Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: projectCards())
                  ]))
              : Container(
                  height: (widget.height == null)
                      ? MediaQuery.of(context).size.height
                      : widget.height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                ),
          TaskMasterFloatingActionButton(
              size: 35,
              iconSize: 25,
              offset: Offset(width - 35 - 20, 30),
              allowed: widget.allowEditing,
              color: Theme.of(context).cardColor,
              iconColor: Theme.of(context).primaryTextTheme.subtitle2!.color!,
              icon: Icons.label,
              onTap: () {
                setState(() {
                  isNewProject = true;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return createLabel();
                    });
              }),
          TaskMasterFloatingActionButton(
              allowed: widget.allowEditing,
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icons.add,
              onTap: () {
                setState(() {
                  isNewProject = true;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return projectName();
                    });
              }),
        ]));
  }
}
