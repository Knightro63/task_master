import 'package:flutter/material.dart';
import 'package:task_master/task_master.dart';
import 'database.dart';
import 'ui.dart';
import 'package:intl/intl.dart';

class BoardViewer extends StatefulWidget {
  const BoardViewer({
    Key? key,
    this.completedData,
    required this.epic,
    required this.project,
    required this.currentUID,
    required this.users,
    required this.width,
    required this.labels,
    required this.height
  }):super(key: key);

  final dynamic labels;
  final String epic;
  final String project;
  final String currentUID;
  final Map<String, dynamic> users;
  final double width;
  final double height;
  final dynamic completedData;

  @override
  State<BoardViewer> createState() => _BoardViewerState();
}

class _BoardViewerState extends State<BoardViewer> {
  String child = '';
  String selectedProject = '';
  String currentEpic = '';
  Map<String, BoardData?> currentBoardData = {};
  Map<String, CardData?> currentCardData = {};
  dynamic labelsData;
  double startingWidth = 0;

  bool showChart = false;

  bool update = false;
  dynamic pointsInfo;

  bool hasStarted = false;
  dynamic completedTasks;

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Initialize variables and start listeners
  void start() async {
    completedTasks = widget.completedData;
    selectedProject = widget.project;
    currentEpic = widget.epic;
    labelsData = widget.labels;
    child = 'department/$currentEpic/$selectedProject';

    if (selectedProject != '') showChart = true;

    startingWidth = widget.width;

    startingWidth = widget.width;

    if(selectedProject.isNotEmpty){
    await Database.once('$child/boards').then((value) {
      if(value != null){
        currentBoardData = boardData(value);
      }
      update = true;
      setState(() {});
    });

    await Database.once('$child/cards').then((value) {
      if(value != null){
        currentCardData = cardData(value);
      }
      update = true;
      hasStarted = true;
      setState(() {});
    });

    await Database.once("points/$currentEpic").then((value) {
      pointsInfo = value;
      setState(() {});
    });
    }

    setState(() {});
  }

  void callback() {
    setState(() {
      update = false;
    });
  }

  // Drop down function included in the package
  List<DropDownItems> createDropDown() {
    List<DropDownItems> dropDownNames = [
      DropDownItems(value: '', text: 'Pick a person')
    ];

    dropDownNames.add(DropDownItems(
        value: widget.currentUID,
        text: widget.users[widget.currentUID]?['displayName'] ?? ''));

    for (String uid in widget.users.keys) {
      if (uid == dropDownNames[1].value) continue;

      dropDownNames.add(
          DropDownItems(value: uid, text: widget.users[uid]?['displayName'] ?? ''));
    }

    return dropDownNames;
  }

  // Pull important data from JSON and to be used in boardManager
  Map<String, BoardData> boardData(dynamic projectBoardData) {
    Map<String, BoardData> data = {};
    if (projectBoardData != null) {
      for (String key in projectBoardData.keys) {
        data[key] = BoardData.fromJSON(
            projectBoardData[key], key, Colors.lightBlue.value);
      }
    }
    return data;
  }

  // Used to pull data from cardData JSON and format it to be used in the managers
  Map<String, CardData> cardData(dynamic projectCardData) {
    Map<String, CardData> data = {};
    if (projectCardData != null) {
      for (String key in projectCardData.keys) {
        Map<String, dynamic>? labels;
        if (labelsData != null &&
            projectCardData[key]['data']?['labels'] != null) {
          for (int i = 0;
              i <= projectCardData[key]['data']['labels'].length - 1;
              i++) {
            if (labelsData[projectCardData[key]['data']['labels'][i]] != null) {
              if (labels == null) {
                labels = {
                  projectCardData[key]['data']['labels'][i]:
                      labelsData[projectCardData[key]['data']['labels'][i]]
                };
              } else {
                labels[projectCardData[key]['data']['labels'][i]] =
                    labelsData[projectCardData[key]['data']['labels'][i]];
              }
            }
          }
        }

        List<String> assigned = [];
        if (projectCardData[key]['data']?['assign'] != null) {
          assigned.add(projectCardData[key]['data']['assign']);
        }
        if (projectCardData[key]['data']?['assigned'] != null) {
          for (int i = 0;
              i < projectCardData[key]['data']['assigned'].length;
              i++) {
            assigned.add(projectCardData[key]['data']['assigned'][i]);
          }
        }

        List<String> editors = [];
        if (projectCardData[key]['data']?['editors'] != null) {
          for (int i = 0;
              i < projectCardData[key]['data']['editors'].length;
              i++) {
            editors.add(projectCardData[key]['data']['editors'][i]);
          }
        }

        // Formats data to be sent to database
        data[key] = CardData(
            id: key,
            title: projectCardData[key]['data']?['title'],
            createdBy: projectCardData[key]['data']?['createdBy'],
            dateCreated: projectCardData[key]['data']?['createdDate'],
            priority: projectCardData[key]['priority'],
            description: projectCardData[key]['data']?['description']  ?? '',
            dueDate: projectCardData[key]['data']?['dueDate'],
            points: projectCardData[key]['data']?['points'] ?? 0,
            assigned: assigned,
            editors: editors,
            checkList: projectCardData[key]['data']?['subTasks'],
            comments: projectCardData[key]['data']?['comments'],
            boardId: projectCardData[key]['board'],
            level: projectCardData[key]['data']?['priority'],
            labels: labels);
      }
    }

    return data;
  }

  // Creates side chart that displays tasks and points
  Widget chartInfo() {
    List<String> names = ['Complete', 'Overdue', 'Planned', 'No Due Date'];
    List<Color> colors = [Colors.blue, Colors.red, Colors.orange, Colors.grey];
    List<int> amount = [0, 0, 0, 0];

    // Cricle indicator that shows how many tasks are in progress, completed, overdue, etc.
    Widget indicator(String text, Color color, int amount, int total) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    //color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(width: 2.5, color: color)),
              ),
              Text(
                ' $text',
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                amount.toString(),
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
              Text(
                ' (${(total == 0 || amount == 0) ? 0 : (amount / total * 100).floor()}%',
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
            ],
          )
        ],
      );
    }

    int total = 0;
    if (currentCardData.isNotEmpty) {
      total = currentCardData.length;
    }

    List<Widget> info = [];
    List<Widget> circles = [];

    // Adds completed tasks to total tasks to display on indicators
    if (completedTasks != null && showChart) {
      int tasks = 0;

      if (completedTasks[currentEpic][selectedProject] != null) {
        tasks += completedTasks[currentEpic][selectedProject].length as int;
      }

      total += tasks;
      amount[0] = tasks;
    }

    List<String> emp = [];
    int maxVal = 0;
    // complete, overdue, planned, pts
    List<List<int>> work = [];
    int i = 0;
    if (pointsInfo != null) {
      for (String key in pointsInfo.keys) {
        emp.add(key);
        work.add([0, 0, 0, 0]);
        if (pointsInfo[key][selectedProject] != null) {
          for (String cKey in pointsInfo[key][selectedProject].keys) {
            work[i][0]++;
            work[i][3] += pointsInfo[key][selectedProject][cKey]['points'] as int;
          }
        }
        i++;
      }
    }

    void checkEmp(String? per, int loc) {
      if (per != null) {
        bool hasPer = false;
        for (int i = 0; i < emp.length; i++) {
          if (per == emp[i]) {
            hasPer = true;
            work[i][loc]++;
            break;
          }
        }
        if (!hasPer) {
          emp.add(per);
          if (loc == 1) {
            work.add([0, 1, 0, 0]);
          } else {
            work.add([0, 0, 1, 0]);
          }
        }
      }
    }

    void getMax() {
      for (int i = 0; i < emp.length; i++) {
        int temp = work[i][0] + work[i][1] + work[i][2];
        if (temp > maxVal) {
          maxVal = temp;
        }
      }
    }

    // Adds tasks to indicators
    if (currentCardData.isNotEmpty) {
      for (String i in currentCardData.keys) {
        if (currentCardData[i]!.dueDate != null) {
          DateTime now = DateTime.now();
          DateTime due =
              DateTime.parse(currentCardData[i]!.dueDate!.replaceAll('T', ' '));
          if (currentCardData[i]!.assigned.isNotEmpty) {
            for (int j = 0; j < currentCardData[i]!.assigned.length; j++) {
              if (now.isAfter(due)) {
                amount[1]++;
                checkEmp(currentCardData[i]!.assigned[j], 1);
              } else {
                amount[2]++;
                checkEmp(currentCardData[i]!.assigned[j], 2);
              }
            }
          }
        } else {
          amount[3]++;
        }
      }
    }
    getMax();

    // Bar charts that display users points
    List<Widget> barChart = [];
    if (completedTasks != null) {
      for (int i = 0; i < emp.length; i++) {
        barChart.add(SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SingleUserIcon(
                    uid: emp[i],
                    color: Colors.teal,
                    loc: 0,
                    iconSize: 35,
                    usersProfile: widget.users,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][0] / maxVal,
                    color: Colors.blue,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][1] / maxVal,
                    color: Colors.red,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][2] / maxVal,
                    color: Colors.orange,
                  ),
                ],
              ),
              RichText(
                  text: TextSpan(
                text: "Pts: ", //+work[i][3].toString(),
                children: [
                  TextSpan(
                    text: work[i][3].toString(),
                    style: TextStyle(
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        fontSize: 10,
                        color:
                            Theme.of(context).primaryTextTheme.subtitle1!.color,
                        decoration: TextDecoration.none),
                  )
                ],
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              )),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
      }
    } else {
      barChart.add(Container());
    }

    double start = 0;
    double finish = 0;
    for (int i = 0; i < 4; i++) {
      info.add(indicator(names[i], colors[i], amount[i], total));
      if (total != 0) {
        start += finish.ceil();
        finish = 360 * (amount[i] / total);

        circles.add(ClipRect(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: OpenPainter(
                      color: colors[i],
                      innerRadius: 150 / 1.9,
                      outerRadius: 150 / 1.9 / (1 + 0.15),
                      total: 1,
                      useStroke: false,
                      percentage: 0.99,
                      startAngle: 360 - start,
                      sweepAngle: finish,
                      setOffset: const Offset(0, 0),
                    ),
                  ),
                ))));
      }
    }
    circles.add(Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              total.toString(),
              style: TextStyle(
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  fontSize: 36,
                  color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                  decoration: TextDecoration.none),
            ),
            Text(
              'Total Tasks',
              style: TextStyle(
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  fontSize: 10,
                  color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                  decoration: TextDecoration.none),
            ),
          ],
        )));

    return Container(
        height: widget.height,
        decoration:
            BoxDecoration(color: Theme.of(context).canvasColor, boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(-5, 3),
          ),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              //padding: EdgeInsets.all(10),
              child: Stack(children: circles),
            ),
            Container(
              width: 180,
              height: 80,
              padding: const EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: info),
            ),
            Container(
              width: 180,
              height: widget.height - 180 - 80,
              padding: const EdgeInsets.all(10),
              child: ListView(
                  padding: const EdgeInsets.all(0),
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: barChart),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedProject != widget.project) {
        setState(() {
          start();
        });
      } else if (widget.completedData != completedTasks) {
        setState(() {
          start();
        });
      }
      if (update) {
        setState(() {});
      } else if (startingWidth != widget.width) {
        setState(() {
          startingWidth = widget.width;
        });
      }
    });

    return hasStarted
        ? SizedBox(
            width: MediaQuery.of(context).size.width - 300,
            height: widget.height,
            child: Stack(
              children: [
                BoardManager(
                    assignPoints: (name, points, id) {
                      print('Name: $name Points: $points ID: $id');
                      //List<String> pushTo = [];
                      DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
                      String createdDate = dayFormatter
                          .format(DateTime.now())
                          .replaceAll(' ', 'T');

                      dynamic archiveData = {
                        'createdBy': currentCardData[id]!.createdBy,
                        'createdDate': currentCardData[id]!.dateCreated,
                        'dueDate': currentCardData[id]!.dueDate,
                        'title': currentCardData[id]!.title,
                        'completedDate': createdDate
                      };

                      if (name != null && points != null) {
                        dynamic pointData = {
                          'assignedBy': widget.currentUID,
                          'dateAssigned': createdDate,
                          'points': points
                        };
                        //print('PointData: $pointData');
                        for (int i = 0; i < name.length; i++) {
                          // if (name[i] != widget.currentUID) {
                          //   pushTo.add(name[i]);
                          // }

                          if(pointsInfo[name[i]] == null){
                            pointsInfo[name[i]] = {selectedProject: {id: pointData}};
                          }
                          else if(pointsInfo[name[i]][selectedProject] == null){
                            pointsInfo[name[i]][selectedProject] = {id: pointData};
                          }
                          else{
                            pointsInfo[name[i]][selectedProject][id] = pointData;
                          }
                        }
                        //print('PointData #2: $pointsInfo');
                        completedTasks[currentEpic][selectedProject][id] = archiveData;
                        currentCardData.removeWhere((key, value) => key==id,);
                      } else {
                        completedTasks[currentEpic][selectedProject][id] = archiveData;
                        currentCardData.removeWhere((key, value) => key==id,);
                        //currentCardData[id] = null;
                      }

                      setState(() {
                        update = true;
                      });
                    },
                    screenOffset: const Offset(180, 0),
                    onPriorityBoardChange: (pri) {
                      for (String key in pri.keys) {
                        currentBoardData[key]!.priority = pri[key];
                      }

                      setState(() {
                        update = true;
                      });
                    },
                    onSubmit: (title, priority, notify) async {
                      String newID = DateTime.now().millisecondsSinceEpoch.toString();

                      currentBoardData[newID] = BoardData(
                        title: title, 
                        dateCreated: DateTime.now().toString(), 
                        createdBy: widget.currentUID, 
                        id: newID,
                        color: Colors.lightBlue.value,
                        priority: priority,
                        notify: notify
                      );
                      setState(() {
                        update = true;
                      });
                    },
                    onEdit: ((data, id) {
                      BoardData editedBroad = BoardData(
                        title: data['title'],
                        dateCreated: data['dateCreated'],
                        createdBy: data['createdBy'],
                        id: id,
                        color: Colors.lightBlue.value,
                        priority: data['priority'],
                        notify: data['notify'],
                      );

                      currentBoardData[id] = editedBroad;

                      setState(() {
                        update = true;
                      });
                    }),
                    onCreateCard: (data) {
                      if (data['data']['assigned'] != null) {
                        List<String> sendTo = [];
                        for (int i = 0;
                            i < data['data']['assigned'].length;
                            i++) {
                          if (data['data']['assigned'][i] !=
                              widget.currentUID) {
                            sendTo.add(data['data']['assigned'][i]);
                          }
                        }

                        setState((){});
                      }

                      Map<String, dynamic> labels = {};
                      if(data['labels'] != null){
                        for(int i = 0; i<= data['labels'].length - 1; i++){
                          labels[data['labels'][i]] = labelsData[data['labels'][i]];
                        }
                      }

                      CardData newCard = CardData(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: data['data']?['title'],
                              createdBy: data['data']?['createdBy'],
                              dateCreated: data['data']?['createdDate'],
                              priority: data['priority'],
                              description: data['data']?['description']  ?? '',
                              dueDate: data['data']?['dueDate'],
                              points: data['data']?['points'] ?? 0,
                              assigned: data['data']['assigned'] ?? [],
                              editors: data['data']['editors'] ?? [],
                              checkList: data['data']?['subTasks'],
                              comments: data['data']?['comments'],
                              boardId: data['board'],
                              level: data['data']?['priority'],
                              labels: labels.isEmpty ? null : labels);

                      setState(() {
                          currentCardData[newCard.id!] = newCard;
                          update = true;
                      });
                    },
                    onEditCard: (data, cardLoc) {
                      List<String> uids = [];
                      int currentCards = 0;

                      for (String i in currentCardData.keys) {
                        if (currentCardData[i]!.id == cardLoc) {
                          currentCards = (currentCardData[i]!.comments == null)
                              ? 0
                              : currentCardData[i]!.comments!.length;
                        }
                      }

                      if (data['assign'] != null &&
                          data['assign'] != widget.currentUID) {
                        uids.add(data['assign']);
                      }

                      if (data['comments'] != null) {
                        if (currentCards != data['comments'].length) {
                          for (String key in data['comments'].keys) {
                            if (data['comments'][key]['createdBy'] !=
                                widget.currentUID) {
                              uids.add(data['comments'][key]['createdBy']);
                            }
                          }
                        }
                      }
                      
                      if (data['assigned'] != null && uids.isNotEmpty) {
                        for (int i = 0; i < data['assigned'].length; i++) {
                          if (data['assigned'][i] != widget.currentUID) {
                            uids.add(data['assigned'][i]);
                          }
                        }
                      }
                      
                      Map<String, dynamic> labels = {};
                      if(data['labels'] != null){
                        for(int i = 0; i<= data['labels'].length - 1; i++){
                          labels[data['labels'][i]] = labelsData[data['labels'][i]];
                        }
                      }

                      CardData editedCard = CardData(
                              id: cardLoc,
                              title: data['title'],
                              createdBy: data['createdBy'],
                              dateCreated: data['createdDate'],
                              priority: currentCardData[cardLoc]!.priority,
                              description: data['description']  ?? '',
                              dueDate: data['dueDate'],
                              points: data['points'] ?? 0,
                              assigned: data['assigned'] ?? [],
                              editors: data['editors'] ?? [],
                              checkList: data['subTasks'],
                              comments: data['comments'],
                              boardId: currentCardData[cardLoc]!.boardId,
                              level: data['priority'],
                              labels: labels.isEmpty ? null : labels);

                      setState(() {
                        currentCardData[cardLoc] = editedCard;

                        update = true;
                      });
                    },
                    onCardDelete: (id) {
                      //currentCardData[id] = null;
                      currentCardData.removeWhere((key, value) => key==id,);
                      setState(() {
                        update = true;
                      });
                    },
                    onCardPriorityChange: (val, change) {
                      for (String j in currentCardData.keys) {
                        if (currentCardData[j]!.id == change['card'] &&
                            currentCardData[j]!.assigned.isNotEmpty) {}
                        if (currentCardData[j]!.id == change['card'] &&
                            currentCardData[j]!.boardId != change['board'] &&
                            currentCardData[j]!.assigned.isNotEmpty) {
                          List<String> allowSend = [];
                          for (int i = 0;
                              i < currentCardData[j]!.assigned.length;
                              i++) {
                            if (currentCardData[j]!.assigned[i] ==
                                widget.currentUID) {
                              allowSend.add(currentCardData[j]!.assigned[i]);
                            }
                          }
                        }
                      }
                      
                      for (String key in val.keys) {
                        currentCardData[key]!.priority = val[key]['priority'];
                        // CardData currentCard = currentCardData[key]!;
                        // Database.update(
                        //     children: '$child/cards',
                        //     location: key,
                        //     data: {
                        //       "board": val[key]['boardId'],
                        //       "priority": val[key]['priority'],
                        //       "data": {
                        //         "assigned": currentCard.assigned,
                        //         "createdBy": currentCard.createdBy,
                        //         "createdDate": currentCard.dateCreated,
                        //         "editors": currentCard.editors,
                        //         "points": currentCard.points,
                        //         "title": currentCard.title,
                        //         "labels": currentCard.labels?.keys.toList(),
                        //         "subTasks": currentCard.checkList,
                        //         "comments": currentCard.comments,
                        //         "description": currentCard.description,
                        //         "priority": currentCard.level,
                        //         "dueDate": currentCard.dueDate
                        //       }
                        //     });
                      }
                      setState(() {
                        update = true;
                      });
                    },
                    onBoardDelete: (id) {
                      //currentBoardData[id] = null;
                      currentBoardData.removeWhere((key, value) => key==id,);
                      setState(() {
                        update = true;
                      });
                    },
                    height: widget.height,
                    width: showChart ? widget.width - 180 : widget.width,
                    labels: labelsData,
                    update: update,
                    callback: callback,
                    projectId: selectedProject,
                    boardData: currentBoardData,
                    cards: currentCardData,
                    users: createDropDown(),
                    usersProfiles: widget.users,
                    currentUser:UserData.fromJSON(widget.users[widget.currentUID], widget.currentUID)),
                selectedProject == ''
                    ? Container()
                    : Align(alignment: Alignment.centerRight, child: chartInfo())
              ],
            ),
          )
        : Container(width: widget.width - 300,color: Theme.of(context).canvasColor);
  }
}
