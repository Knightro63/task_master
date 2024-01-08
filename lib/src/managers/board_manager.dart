import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../spell_checker/spell_checker.dart';
import '../../task_master.dart';
import '../../task_card.dart';
import '../task_widgets.dart';
import '../util/textformfield.dart';

class BoardManager extends StatefulWidget {
  const BoardManager({
    Key? key,
    required this.update,
    this.onSubmit,
    this.onEdit,
    this.onTitleChange,
    this.onFocusNode,
    this.callback,
    this.onBoardDelete,
    this.onPriorityBoardChange,
    this.onCreateCard,
    this.assignPoints,
    this.onEditCard,
    this.onCardDelete,
    this.onCardPriorityChange,
    required this.projectId,
    required this.boardData,
    required this.cards,
    this.width,
    this.height,
    this.boardWidth = 240,
    this.allowEditing = true,
    this.screenOffset = const Offset(0, 0),
    required this.users,
    required this.usersProfiles,
    required this.currentUser,
    this.labels,
  }) : super(key: key);

  /// Callback for board submision/creationj
  final Function(String title, int priority, bool notify)? onSubmit;

  /// Callback for board edit
  final Function(dynamic data, String id)? onEdit;

  /// Callback for board deletion
  final Function(String id)? onBoardDelete;

  // Callback for card deletion
  final Function(String id)? onCardDelete;

  /// ID of project that contains the boards
  final String projectId;

  final Function()? onFocusNode;

  /// Callback for board priority change
  final Function(Map<String, int> priority)? onPriorityBoardChange;

  /// Callback for card creation
  final Function(Map<String, dynamic> data)? onCreateCard;

  /// Callback for card editing
  final Function(Map<String, dynamic> data, String id)? onEditCard;

  /// Callback for point assignment
  final Function(List<String>? name, int? points, String id)? assignPoints;

  /// Callback for card priority change
  final Function(Map<String, dynamic> priority, dynamic change)?
      onCardPriorityChange;

  /// Callback for title change
  final Function(String id, String title)? onTitleChange;

  /// Map of BoardData
  final Map<String, BoardData?> boardData;

  /// Map of CardData
  final Map<String, CardData?> cards;

  /// Width of the Manager
  final double? width;

  /// Height of the manager
  final double? height;

  /// Width of each board
  final double boardWidth;

  /// Boolean denoting whether or not the boards/cards can be added, edited or deleted.
  final bool allowEditing;

  /// A dropdown of all the users to be used for assignment to tasks
  final List<DropDownItems> users;

  ///
  final void Function()? callback;

  ///
  final Offset screenOffset;

  /// Label Data
  final dynamic labels;

  /// Value to indicate if there has been an update
  final bool update;

  /// All valid user profiles to be used, should be provided as JSON represented in a Map
  final Map<String, dynamic> usersProfiles;

  /// Current user that is viewing the application
  final UserData currentUser;

  @override
  _BoardManagerState createState() => _BoardManagerState();
}

class _BoardManagerState extends State<BoardManager> {
  double width = 100;
  double height = 100;
  double cardHeight = 61;
  double boardWidth = 100;

  final ScrollController _scrollController = ScrollController();
  TextEditingController labelNameController = TextEditingController();
  TextEditingController boardNameController = TextEditingController();

  bool error = false;
  bool needsUpdate = false;
  bool isNewLabel = true;
  bool isNewCard = true;
  bool allowNofifying = false;
  bool updateBoard = false;
  bool expandCheck = false;
  bool expandComments = false;

  List<TextEditingController> nameChangeController = [];
  List<int> hexColors = [
    0xffff0000,
    0xff00ff00,
    0xff0000ff,
    0xff009688,
    0xffff9800,
    0xff3f51b5,
    0xff
  ];
  List cardNameControllers = [
    SpellCheckController(),
    SpellCheckController(),
    TextEditingController()
  ];
  List<String> listId = [];
  List<TextEditingController> activityControllers = [];
  List<TextEditingController> checkControllers = [];
  List<bool> checkList = [];
  List<String> pickedLabels = [];
  List<String> boardLoc = [];
  List<int> boardCards = [];

  List<DropdownMenuItem<dynamic>> assignDropDown = [];
  List<DropdownMenuItem<dynamic>> editorDropDown = [];
  List<DropdownMenuItem<String>> priDropDown = [];
  List<BoardData> boardData = [];
  List<CardData> cardData = [];

  Map<String, List<String>>? cardComments;
  Map<String, List<String>>? cardCheckList;

  String boardBeingDragged = '';
  String boardId = '';
  List<String> assigned = [];
  List<String> editors = [];
  String level = 'Priority';
  String assignedDate = '';
  String boardIdCardDragged = '';
  String boardStartIdCardDragged = '';
  String cardBeingDragged = '';

  DateTime selectedDate = DateTime.now();

  int? selectedCard;
  int? carredDraggedLoc;
  int? draggedLoc;
  int projectClickedColor = 7;
  int nextIndex = 0;
  int updateBoardId = 0;

  dynamic labelData;

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  // Initlizes default state of boardManager
  void start() {
    labelData = widget.labels;
    height = (widget.height == null)
        ? MediaQuery.of(context).size.height
        : widget.height!;
    width = (widget.width == null)
        ? MediaQuery.of(context).size.width
        : widget.width!;
    boardWidth = widget.boardWidth;
    cardData = widget.cards.entries.map((e)=>e.value).whereType<CardData>().toList();
    boardData = widget.boardData.entries.map((e) => e.value).whereType<BoardData>().toList();
    assignDropDown = setDropDownItems(widget.users);
    editorDropDown = setDropDownItems(widget.users);
    priDropDown = setDropDownItems([
      DropDownItems(value: 'Priority', text: 'Priority'),
      DropDownItems(value: 'Low', text: 'Low'),
      DropDownItems(value: 'Medium', text: 'Medium'),
      DropDownItems(value: 'High', text: 'High'),
    ]);

    cardReset();
    boardReset();
    sortByPriority();
    sortByCardPriority();
    setState(() {});
  }

  /// Reset Card to Data to its defaults
  void cardReset() {
    cardComments = null;
    cardCheckList = null;
    selectedCard = null;
    isNewCard = true;
    boardId = '';
    pickedLabels = [];
    cardNameControllers = [
      SpellCheckController(),
      SpellCheckController(),
      TextEditingController()
    ];
    activityControllers = [];
    checkControllers = [];
    checkList = [];
    assigned = [];
    editors = [];
    level = 'Priority';
    assignedDate = '';
    selectedDate = DateTime.now();
  }

  /// Gets card data from selected card [i] and populates the their respective fields
  Future<void> cardSet(int i) async {
    await Future.delayed(const Duration(milliseconds: 250), (() {
      cardReset();
      selectedCard = i;
      isNewCard = false;
      error = false;
      if (cardData[i].title != null) {
        cardNameControllers[0].text = cardData[i].title;
      }
      if (cardData[i].description != null) {
        cardNameControllers[1].text = cardData[i].description;
      }
      if (cardData[i].points != null) {
        cardNameControllers[2].text = cardData[i].points.toString();
      }
      if (cardData[i].assigned.isNotEmpty) {
        cardData[i].assigned.forEach((element) {
          assigned.add(element);
        });
      }
      if (cardData[i].editors.isNotEmpty) {
        cardData[i].editors.forEach((element) {
          editors.add(element);
        });
      } else if (cardData[i].editors.isEmpty) {
        String? createdBy = (isNewCard)
            ? widget.currentUser.uid
            : cardData[selectedCard!].createdBy;
        if (createdBy != null) {
          editors.add(createdBy);
        }
      }
      if (cardData[i].level != null) {
        level = cardData[i].level!;
      }
      if (cardData[i].dueDate != null) {
        assignedDate = cardData[i].dueDate!.split('T')[0];
        selectedDate =
            DateTime.parse(cardData[i].dueDate!.replaceAll('T', ' '));
      }
      if (cardData[i].labels != null) {
        for (String key in cardData[i].labels!.keys) {
          pickedLabels.add(key);
        }
      }
      if (cardData[i].checkList != null) {
        List<String> names = [];
        List<String> dates = [];
        for (int j = 0; j < cardData[i].checkList!.length; j++) {
          String st = 'st_$j';
          checkControllers.add(SpellCheckController());
          checkList.add(cardData[i].checkList![st]['checked']);
          checkControllers[j].text = cardData[i].checkList![st]['task'];
          names.add(cardData[i].checkList![st]['createdBy']);
          dates.add(cardData[i].checkList![st]['dateCreated']);
        }
        cardCheckList = {
          'names': names,
          'dates': dates,
        };
      }
      if (cardData[i].comments != null) {
        List<String> names = [];
        List<String> dates = [];
        for (int j = 0; j < cardData[i].comments!.length; j++) {
          String ac = 'act_$j';
          activityControllers.add(SpellCheckController());
          activityControllers[j].text = cardData[i].comments![ac]['comment'];
          names.add(cardData[i].comments![ac]['createdBy']);
          dates.add(cardData[i].comments![ac]['dateCreated']);
        }
        cardComments = {
          'names': names,
          'dates': dates,
        };
      }
    }));
  }

  /// Resets the board
  void boardReset() {
    error = false;
    updateBoard = false;
    boardNameController.text = '';
    allowNofifying = false;
  }

  /// Opens dialog that is used to edit board [id]'s title and notification status
  void boardSet(int id) {
    boardReset();
    boardNameController.text = boardData[id].title;
    allowNofifying = boardData[id].notify;
    updateBoard = true;
    updateBoardId = id;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return boardName();
        });
  }

  /// Prepares card data into JSON format to be sent to database
  void submitCardData() {
    DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
    String dueDate = '';
    if (assignedDate != '') {
      dueDate = dayFormatter.format(selectedDate).replaceAll(' ', 'T');
    }
    String createdDate =
        dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
    dynamic subtasks;
    dynamic activities;
    int priority = 0;

    if (checkControllers.isNotEmpty) {
      for (int i = 0; i < checkControllers.length; i++) {
        String st = 'st_$i';
        if (checkControllers[i].text != '') {
          if (subtasks == null) {
            subtasks = {
              st: {
                'task': checkControllers[i].text,
                'checked': checkList[i],
                'dateCreated': cardCheckList!['dates']![i],
                'createdBy': cardCheckList!['names']![i],
              }
            };
          } else {
            subtasks[st] = {
              'task': checkControllers[i].text,
              'checked': checkList[i],
              'dateCreated': cardCheckList!['dates']![i],
              'createdBy': cardCheckList!['names']![i],
            };
          }
        }
      }
    }
    if (activityControllers.isNotEmpty) {
      for (int i = 0; i < activityControllers.length; i++) {
        String st = 'act_$i';
        if (activityControllers[i].text != '') {
          if (activities == null) {
            activities = {
              st: {
                'comment': activityControllers[i].text,
                'dateCreated': cardComments!['dates']![i],
                'createdBy': cardComments!['names']![i],
              }
            };
          } else {
            activities[st] = {
              'comment': activityControllers[i].text,
              'dateCreated': cardComments!['dates']![i],
              'createdBy': cardComments!['names']![i],
            };
          }
        }
      }
    }
    if (cardData.isNotEmpty) {
      for (int i = 0; i < cardData.length; i++) {
        if (boardId == cardData[i].boardId) {
          priority++;
        }
      }
    }
    String? createdBy = (isNewCard)
        ? widget.currentUser.uid
        : cardData[selectedCard!].createdBy;

    Map<String, dynamic> data = {
      'title': (cardNameControllers[0].text == '')
          ? 'Temp Title'
          : cardNameControllers[0].text,
      'points': (cardNameControllers[2].text == '')
          ? null
          : int.parse(cardNameControllers[2].text),
      'description': (cardNameControllers[1].text == '')
          ? null
          : cardNameControllers[1].text,
      'assigned': (assigned.isEmpty) ? null : assigned,
      'editors': editors,
      'createdBy': createdBy,
      'dueDate': (dueDate == '') ? null : dueDate,
      'createdDate':
          (isNewCard) ? createdDate : cardData[selectedCard!].dateCreated,
      'subTasks': subtasks,
      'comments': activities,
      'labels': pickedLabels,
      'priority': (level == 'Priority') ? null : level,
    };

    Map<String, dynamic> toSend = {
      'data': data,
      'board': boardId,
      'project': widget.projectId,
      'priority': priority
    };
    if (widget.onCreateCard != null && isNewCard) {
      widget.onCreateCard!(toSend);
    } else if (widget.onEditCard != null) {
      widget.onEditCard!(data, cardData[selectedCard!].id!);
    }
  }

  /// Reorders cardData based on their priorities
  void sortByCardPriority() {
    boardLoc = [];
    boardCards = [];

    if (cardData.isNotEmpty) {
      List<CardData> tempData = [];
      for (int i = 0; i < boardData.length; i++) {
        boardLoc.add(boardData[i].id);
        boardCards.add(0);
      }

      for (int i = 0; i < boardLoc.length; i++) {
        List<CardData> sortLocData = [];

        for (int j = 0; j < cardData.length; j++) {
          if (cardData[j].boardId == boardLoc[i]) {
            sortLocData.add(cardData[j]);
            boardCards[i]++;
          }
        }
        sortLocData.sort((a, b) => a.priority!.compareTo(b.priority!));
        tempData += sortLocData;
      }
      setState(() {
        cardData = tempData;
      });
    }
  }

  /// Will set a [boardId] card's new priority and location [newLoc]
  void reorderCards(int newLoc, String boardId) {
    //set cards new priority and loc
    for (int i = 0; i < cardData.length; i++) {
      if (cardData[i].id == cardBeingDragged) {
        cardData[i].priority = newLoc;
        cardData[i].boardId = boardId;
        break;
      }
    }
    //change priorities
    int j = 0;
    String tempID = boardLoc[0];
    for (int i = 0; i < cardData.length; i++) {
      if (cardData[i].id != cardBeingDragged) {
        if (tempID != cardData[i].boardId) {
          if (newLoc == 0 && cardData[i].boardId == boardId) {
            j = 1;
          } else {
            j = 0;
          }
          tempID = cardData[i].boardId!;
        } else if (newLoc == j && cardData[i].boardId == boardId) {
          j++;
        }
        cardData[i].priority = j;
        j++;
      }
    }
  }

  /// Will update card priority and reorder cards are drag
  void updateCardPriority(Offset details) {
    double startPosX =
        (details.dx - widget.screenOffset.dx) + _scrollController.offset;
    double startPosY = (details.dy - 66 - 40 - 70) - widget.screenOffset.dy;
    if (startPosY > 0) {
      int newYLoc = (startPosY / cardHeight).floor();
      int newXLoc = (startPosX / boardWidth).floor();

      if (newXLoc > boardData.length - 1) {
        newXLoc = boardData.length - 1;
      } else if (newXLoc < 0) {
        newXLoc = 0;
      }
      String newBoard = boardLoc[newXLoc];

      if (newYLoc > boardCards[newXLoc] - 1) {
        newYLoc = boardCards[newXLoc] - 1;
      } else if (newYLoc < 0) {
        newYLoc = 0;
      }

      if (carredDraggedLoc != newYLoc || boardIdCardDragged != newBoard) {
        reorderCards(newYLoc, newBoard);
        sortByCardPriority();
        carredDraggedLoc = newYLoc;
        boardIdCardDragged = newBoard;
      }
    }
  }

  /// Will format card priority change data and send to database using [onCardPriorityChange] callback function
  void priorityCardChange() {
    Map<String, dynamic> pri = {};
    for (int i = 0; i < cardData.length; i++) {
      pri[cardData[i].id!] = {
        'priority': cardData[i].priority,
        'boardId': cardData[i].boardId
      };
    }
    dynamic data = {'card': cardBeingDragged, 'board': boardStartIdCardDragged};
    if (widget.onCardPriorityChange != null) {
      widget.onCardPriorityChange!(pri, data);
    }
  }

  /// Sorts boards by priorities and adds them to [boardLoc]
  void sortByPriority() {
    boardLoc = [];
    setState(() {
      boardData.sort((a, b) => a.priority!.compareTo(b.priority!));
    });
    for (int i = 0; i < boardData.length; i++) {
      boardLoc.add(boardData[i].id);
    }
  }

  /// Updates prioritiesof board based on the calculated [newDragLoc]
  void updatePriority(Offset details) {
    double startPosX =
        (details.dx - widget.screenOffset.dx) + _scrollController.offset;
    if (startPosX > 0) {
      int newDragLoc = (startPosX / boardWidth).floor();
      if (newDragLoc > boardData.length - 1) {
        newDragLoc = boardData.length - 1;
      } else if (newDragLoc < 0) {
        newDragLoc = 0;
      }
      if (draggedLoc != newDragLoc) {
        reorder(draggedLoc!, newDragLoc);
        setPriority(newDragLoc);
        sortByPriority();
        draggedLoc = newDragLoc;
      }
    }
  }

  /// Sets new priority of board based on [newDragLoc]
  void setPriority(int newDragLoc) {
    for (int i = 0; i < boardData.length; i++) {
      if (boardData[i].id == boardBeingDragged) {
        boardData[i].priority = newDragLoc;
        break;
      }
    }
  }

  // Reorders boardData based on oldLoc and newLoc
  void reorder(int oldLoc, int newLoc) {
    for (int i = 0; i < boardData.length; i++) {
      if (boardData[i].priority == newLoc) {
        boardData[i].priority = oldLoc;
        break;
      }
    }
  }

  /// Formats changes to board priorities and sends it to the database using the [onPriorityBoardChange] callback parameter
  void priorityChange() {
    Map<String, int> pri = {};
    for (int i = 0; i < boardData.length; i++) {
      pri[boardData[i].id] = boardData[i].priority!;
    }

    if (widget.onPriorityBoardChange != null) {
      widget.onPriorityBoardChange!(pri);
    }
  }

  /// Builds date picker and updates [assignedDate] and [selectedDate] accordingly
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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

  // Widget for draggable cards
  Widget dragCard(String id, int index, int cardToUse) {
    return Stack(
      children: [
        (cardBeingDragged != cardData[cardToUse].id)
            ? CreateTaskCard(
                users: widget.usersProfiles,
                context: context,
                cardData: cardData[cardToUse],
                height: cardHeight,
                width: boardWidth - 40.0)
            : Container(),
        Draggable(
          data: 1,
          feedback: CreateTaskCard(
              users: widget.usersProfiles,
              context: context,
              cardData: cardData[cardToUse],
              height: cardHeight,
              rotate: true,
              width: boardWidth - 40.0),
          child: const Padding(
              padding: EdgeInsets.only(top: 2, left: 2),
              child: Icon(Icons.drag_indicator)),
          onDragStarted: () {
            setState(() {
              carredDraggedLoc = cardData[cardToUse].priority!;
              boardStartIdCardDragged = cardData[cardToUse].boardId!;
              boardIdCardDragged = cardData[cardToUse].boardId!;
              cardBeingDragged = cardData[cardToUse].id!;
            });
          },
          onDragEnd: (val) {
            setState(() {
              priorityCardChange();
              cardBeingDragged = '';
              boardIdCardDragged = '';
            });
          },
          onDragCompleted: () {
            setState(() {
              priorityCardChange();
              cardBeingDragged = '';
              boardIdCardDragged = '';
            });
          },
          onDraggableCanceled: (vel, off) {
            setState(() {
              priorityCardChange();
              cardBeingDragged = '';
              boardIdCardDragged = '';
            });
          },
        )
      ],
    );
  }

  /// Opens dialog menu with editable card information of [cardToUse] if [cardToUse] is null, assuming creating a new card, edited by current user
  Widget cardName(int? cardToUse) {
    if (cardToUse == null) {
      editors.add(widget.currentUser.uid);
    }
    String tempAssign = '';
    String tempEditor = '';
    bool cardUpdateReady = false;
    double width = (deviceWidth - responsive(width: widget.width)) / 4;

    return StatefulBuilder(builder: (context, setState) {
      if (!cardUpdateReady) {
        if (cardToUse != null) {
          cardSet(cardToUse).then((value) {
            setState(() {
              cardUpdateReady = true;
            });
          });
        } else {
          cardUpdateReady = true;
        }
      }
      bool isEditor() {
        if (isNewCard) return true;
        if (editors.isNotEmpty) {
          for (int i = 0; i < editors.length; i++) {
            if (editors[i] == widget.currentUser.uid) {
              return true;
            }
          }
        }
        return false;
      }

      // Creates activity list for the card
      Widget createActivityList() {
        Widget section(int i) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(children: [
                      Text(
                        widget.usersProfiles[cardComments!['names']![i]]
                            ['displayName'],
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .subtitle1!
                                .color,
                            fontSize: 14,
                            fontFamily: 'Klavika Bold',
                            package: 'css',
                            decoration: TextDecoration.none),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cardComments!['dates']![i],
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .subtitle1!
                                .color,
                            fontSize: 12,
                            fontFamily: 'MeuseoSans',
                            decoration: TextDecoration.none),
                      ),
                    ])),
                EnterTextFormField(
                    width: responsive(width: widget.width) - 50,
                    //height: 35,
                    color: Theme.of(context).canvasColor,
                    maxLines: null,
                    label: 'Write a Comment',
                    controller: activityControllers[i],
                    onEditingComplete: () {},
                    onSubmitted: (val) {},
                    onTap: widget.onFocusNode),
              ]);
        }

        if (activityControllers.isNotEmpty) {
          List<Widget> rows = [];
          for (int i = 0; i < activityControllers.length; i++) {
            rows.add(section(i));
            rows.add(const SizedBox(height: 5));
          }
          return SizedBox(
              height: (activityControllers.length < 3 || expandComments)
                  ? activityControllers.length * 57.0
                  : 57.0 * 3,
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: rows,
              ));
        } else {
          return const SizedBox();
        }
      }

      // Creates the checklist for the card
      Widget createCheckList() {
        Widget section(int i) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(
                          widget.usersProfiles[cardCheckList!['names']![i]]
                              ['displayName'],
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .subtitle1!
                                  .color,
                              fontSize: 14,
                              fontFamily: 'Klavika Bold',
                              package: 'css',
                              decoration: TextDecoration.none),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          cardCheckList!['dates']![i],
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .subtitle1!
                                  .color,
                              fontSize: 12,
                              fontFamily: 'MeuseoSans',
                              decoration: TextDecoration.none),
                        ),
                      ],
                    )),
                Row(
                  children: [
                    SizedBox(
                        width: 35,
                        height: 20,
                        child: Checkbox(
                            activeColor: Theme.of(context).secondaryHeaderColor,
                            checkColor: Colors.white,
                            value: checkList[i],
                            onChanged: (val) {
                              setState(() {
                                checkList[i] = val!;
                              });
                            })),
                    EnterTextFormField(
                      margin: const EdgeInsets.all(0),
                      width: responsive(width: widget.width) - 80,
                      //height:35,
                      color: Theme.of(context).canvasColor,
                      maxLines: null,
                      label: 'Task Name',
                      controller: checkControllers[i],
                      onEditingComplete: () {},
                      onSubmitted: (val) {},
                      onTap: widget.onFocusNode,
                    ),
                  ],
                )
              ]);
        }

        if (checkControllers.isNotEmpty) {
          List<Widget> rows = [];
          for (int i = 0; i < checkControllers.length; i++) {
            rows.add(section(i));
            rows.add(const SizedBox(height: 5));
          }
          return SizedBox(
              height: (checkControllers.length < 3 || expandCheck)
                  ? checkControllers.length * 57.0
                  : 57.0 * 3,
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: rows,
              ));
        } else {
          return const SizedBox();
        }
      }

      // Creates labels in card dialog
      Widget createLabels() {
        List<Widget> label = [];
        if (labelData != null) {
          for (String key in labelData.keys) {
            if (labelData[key] == null) continue;
            Color textColor =
                Color(labelData[key]['color']).computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white;
            bool isLabelSelected = false;
            for (int i = 0; i < pickedLabels.length; i++) {
              if (pickedLabels[i] == key) {
                isLabelSelected = true;
                break;
              }
            }
            label.add(InkWell(
                onTap: () {
                  bool isAllowed = true;
                  int area = 0;
                  for (int i = 0; i < pickedLabels.length; i++) {
                    if (pickedLabels[i] == key) {
                      isAllowed = false;
                      area = i;
                      break;
                    }
                  }
                  if (isAllowed) {
                    setState(() {
                      pickedLabels.add(key);
                    });
                  } else {
                    setState(() {
                      pickedLabels.removeAt(area);
                    });
                  }
                },
                child: Container(
                  width: 80,
                  height: 20,
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Color(labelData[key]['color']),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        (isLabelSelected)
                            ? Icon(Icons.check, color: textColor, size: 12)
                            : Container(),
                        Text(labelData[key]['name'],
                            style: TextStyle(
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 12,
                                color: textColor))
                      ]),
                )));
          }
        } else {
          label.add(Container());
        }
        return Wrap(children: label);
      }

      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.only(left: 1, right: 1),
          child: Container(
              padding: const EdgeInsets.all(20),
              height: height,
              width: responsive(width: widget.width),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ]),
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  cardUpdateReady
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              SizedBox(
                                  height: height - 65 - 40,
                                  child: ListView(
                                    padding: const EdgeInsets.all(0),
                                    children: [
                                      Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          children: [
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.title_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: responsive(
                                                            width:
                                                                widget.width) -
                                                        60,
                                                    child: EnterTextFormField(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      height: 35,
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      maxLines: 1,
                                                      label: 'Title',
                                                      controller:
                                                          cardNameControllers[
                                                              0],
                                                      onTap: widget.onFocusNode,
                                                    ),
                                                  ),
                                                ]),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                width: 120,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (widget.allowEditing ||
                                                        isNewCard) {
                                                      _selectDate(context);
                                                    }
                                                  },
                                                  child: TaskWidgets.iconNote(
                                                      Icons
                                                          .insert_invitation_outlined,
                                                      (assignedDate == '')
                                                          ? DateFormat(
                                                                  'y-MM-dd')
                                                              .format(DateTime
                                                                  .now())
                                                          : assignedDate,
                                                      TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .bodyText2!
                                                              .color,
                                                          fontFamily: 'Klavika',
                                                          package: 'css',
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                      20),
                                                )),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                width: 100,
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.plus_one_rounded,
                                                        size: 20,
                                                      ),
                                                      SizedBox(
                                                          width: 80,
                                                          child:
                                                              EnterTextFormField(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            readOnly:
                                                                !isEditor(),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            width: 50.0,
                                                            height: 35,
                                                            color: Theme.of(
                                                                    context)
                                                                .canvasColor,
                                                            maxLines: 1,
                                                            label: 'Points',
                                                            controller:
                                                                cardNameControllers[
                                                                    2],
                                                            onEditingComplete:
                                                                () {},
                                                            onSubmitted:
                                                                (val) {},
                                                            onTap: widget
                                                                .onFocusNode,
                                                          ))
                                                    ])),
                                            SizedBox(
                                                width: 100,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .priority_high_rounded,
                                                        size: 20),
                                                    (widget.allowEditing ||
                                                            level ==
                                                                'Priority' ||
                                                            isNewCard)
                                                        ? dropDown(
                                                            itemVal:
                                                                priDropDown,
                                                            radius: 5,
                                                            value: level,
                                                            width: 80,
                                                            color: Theme.of(
                                                                    context)
                                                                .canvasColor,
                                                            onchange: (val) {
                                                              setState(() {
                                                                level = val;
                                                              });
                                                            })
                                                        : Container(
                                                            width: 100,
                                                            height: 36,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .canvasColor,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          5)),
                                                            ),
                                                            child: Text(
                                                              level,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryTextTheme
                                                                      .bodyText2!
                                                                      .color,
                                                                  fontFamily:
                                                                      'Klavika',
                                                                  package:
                                                                      'css',
                                                                  fontSize: 20,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none),
                                                            )),
                                                  ],
                                                )),
                                            SizedBox(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  TaskWidgets.iconNote(
                                                      Icons.label,
                                                      "Labels",
                                                      TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .bodyText2!
                                                              .color,
                                                          fontFamily: 'Klavika',
                                                          package: 'css',
                                                          fontSize: 20,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                      20),
                                                  createLabels()
                                                ])),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .assignment_late_outlined,
                                                        size: 20,
                                                      ),
                                                      UserIcon(
                                                          remove: (loc) {
                                                            setState(() {
                                                              editors.removeAt(
                                                                  loc);
                                                            });
                                                          },
                                                          viewidth: responsive(
                                                                  width: widget
                                                                      .width) -
                                                              60,
                                                          uids: editors,
                                                          colors: [
                                                            Colors.teal[200]!,
                                                            Colors.teal[600]!
                                                          ],
                                                          usersProfile: widget
                                                              .usersProfiles)
                                                    ])),
                                            assigned.isNotEmpty
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .assignment_ind,
                                                            size: 20,
                                                          ),
                                                          UserIcon(
                                                            remove: (loc) {
                                                              setState(() {
                                                                assigned
                                                                    .removeAt(
                                                                        loc);
                                                              });
                                                            },
                                                            viewidth: responsive(
                                                                    width: widget
                                                                        .width) -
                                                                60,
                                                            uids: assigned,
                                                            colors: [
                                                              Colors.teal[200]!,
                                                              Colors.teal[600]!
                                                            ],
                                                            usersProfile: widget
                                                                .usersProfiles,
                                                          )
                                                        ]))
                                                : Container()
                                          ]),
                                      const SizedBox(height: 20),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TaskWidgets.iconNote(
                                                  Icons.assignment,
                                                  "Assign",
                                                  TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryTextTheme
                                                          .bodyText2!
                                                          .color,
                                                      fontFamily: 'Klavika',
                                                      package: 'css',
                                                      fontSize: 20,
                                                      decoration:
                                                          TextDecoration.none),
                                                  20),
                                              SizedBox(
                                                width: 150,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    dropDown(
                                                        itemVal: assignDropDown,
                                                        value: tempAssign,
                                                        radius: 5,
                                                        width: 120,
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        onchange: (val) {
                                                          setState(() {
                                                            tempAssign = val;
                                                          });
                                                        }),
                                                    InkWell(
                                                      onTap: () {
                                                        if (isEditor()) {
                                                          bool allowedAdd =
                                                              true;
                                                          if (assigned
                                                                  .isNotEmpty &&
                                                              tempAssign !=
                                                                  '') {
                                                            for (int i = 0;
                                                                i <
                                                                    assigned
                                                                        .length;
                                                                i++) {
                                                              if (tempAssign ==
                                                                  assigned[i]) {
                                                                allowedAdd =
                                                                    false;
                                                                break;
                                                              }
                                                            }
                                                          }
                                                          setState(() {
                                                            if (allowedAdd &&
                                                                tempAssign !=
                                                                    '') {
                                                              assigned.add(
                                                                  tempAssign);
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add_box,
                                                        size: 30,
                                                        color: Theme.of(context)
                                                            .primaryTextTheme
                                                            .bodyText2!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TaskWidgets.iconNote(
                                                  Icons.edit_note_rounded,
                                                  "Editor",
                                                  TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryTextTheme
                                                          .bodyText2!
                                                          .color,
                                                      fontFamily: 'Klavika',
                                                      package: 'css',
                                                      fontSize: 20,
                                                      decoration:
                                                          TextDecoration.none),
                                                  20),
                                              SizedBox(
                                                width: 150,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    dropDown(
                                                        itemVal: editorDropDown,
                                                        value: tempEditor,
                                                        radius: 5,
                                                        width: 120,
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        onchange: (val) {
                                                          setState(() {
                                                            tempEditor = val;
                                                          });
                                                        }),
                                                    InkWell(
                                                      onTap: () {
                                                        if (isEditor()) {
                                                          bool allowedAdd =
                                                              true;
                                                          if (editors
                                                                  .isNotEmpty &&
                                                              tempEditor !=
                                                                  '') {
                                                            for (int i = 0;
                                                                i <
                                                                    editors
                                                                        .length;
                                                                i++) {
                                                              if (tempEditor ==
                                                                  editors[i]) {
                                                                allowedAdd =
                                                                    false;
                                                                break;
                                                              }
                                                            }
                                                          }
                                                          setState(() {
                                                            if (allowedAdd &&
                                                                tempEditor !=
                                                                    '') {
                                                              editors.add(
                                                                  tempEditor);
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add_box,
                                                        size: 30,
                                                        color: Theme.of(context)
                                                            .primaryTextTheme
                                                            .bodyText2!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TaskWidgets.iconNote(
                                          Icons.grading_rounded,
                                          "Description",
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
                                      EnterTextFormField(
                                        color: Theme.of(context).canvasColor,
                                        minLines: 3,
                                        label: 'Tasks Description',
                                        controller: cardNameControllers[1],
                                        onEditingComplete: () {},
                                        onSubmitted: (val) {},
                                        onTap: widget.onFocusNode,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  expandCheck = !expandCheck;
                                                });
                                              },
                                              child: Icon(
                                                (!expandCheck)
                                                    ? Icons.expand
                                                    : Icons.clear_outlined,
                                                color: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2!
                                                    .color,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            TaskWidgets.iconNote(
                                                Icons.check_box,
                                                "Checklist",
                                                TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryTextTheme
                                                        .bodyText2!
                                                        .color,
                                                    fontFamily: 'Klavika',
                                                    package: 'css',
                                                    fontSize: 20,
                                                    decoration:
                                                        TextDecoration.none),
                                                20)
                                          ]),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                checkControllers.add(
                                                    SpellCheckController());
                                                checkList.add(false);
                                                DateFormat dayFormatter =
                                                    DateFormat('y-MM-dd');
                                                String createdDate =
                                                    dayFormatter
                                                        .format(DateTime.now());
                                                if (cardCheckList == null) {
                                                  cardCheckList = {
                                                    'names': [
                                                      widget.currentUser.uid
                                                    ],
                                                    'dates': [createdDate]
                                                  };
                                                } else {
                                                  cardCheckList!['names']!.add(
                                                      widget.currentUser.uid);
                                                  cardCheckList!['dates']!
                                                      .add(createdDate);
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.add_box,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyText2!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          color: lighten(
                                              Theme.of(context).canvasColor,
                                              0.2),
                                          child: createCheckList()),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  expandComments =
                                                      !expandComments;
                                                });
                                              },
                                              child: Icon(
                                                (!expandComments)
                                                    ? Icons.expand
                                                    : Icons.clear_outlined,
                                                color: Theme.of(context)
                                                    .primaryTextTheme
                                                    .bodyText2!
                                                    .color,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            TaskWidgets.iconNote(
                                                Icons.list_rounded,
                                                "Comments",
                                                TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryTextTheme
                                                        .bodyText2!
                                                        .color,
                                                    fontFamily: 'Klavika',
                                                    package: 'css',
                                                    fontSize: 20,
                                                    decoration:
                                                        TextDecoration.none),
                                                20)
                                          ]),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                activityControllers.add(
                                                    SpellCheckController());
                                                DateFormat dayFormatter =
                                                    DateFormat('y-MM-dd');
                                                String createdDate =
                                                    dayFormatter
                                                        .format(DateTime.now());
                                                if (cardComments == null) {
                                                  cardComments = {
                                                    'names': [
                                                      widget.currentUser.uid
                                                    ],
                                                    'dates': [createdDate]
                                                  };
                                                } else {
                                                  cardComments!['names']!.add(
                                                      widget.currentUser.uid);
                                                  cardComments!['dates']!
                                                      .add(createdDate);
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.add_box,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyText2!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          color: lighten(
                                              Theme.of(context).canvasColor,
                                              0.2),
                                          child: createActivityList()),
                                    ],
                                  )),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    (!isNewCard && isEditor())
                                        ? squareButton(
                                            text: 'delete',
                                            onTap: () {
                                              setState(() {
                                                if (widget.onCardDelete !=
                                                    null) {
                                                  widget.onCardDelete!(
                                                      cardData[selectedCard!]
                                                          .id!);
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            buttonColor: Colors.transparent,
                                            borderColor: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText2!
                                                .color,
                                            height: 45,
                                            radius: 45 / 2,
                                            width:
                                                responsive(width: width) / 3 -
                                                    10,
                                          )
                                        : Container(),
                                    (!isNewCard && isEditor())
                                        ? squareButton(
                                            fontSize: 16,
                                            text: 'complete',
                                            onTap: () {
                                              setState(() {
                                                if (widget.assignPoints !=
                                                    null) {
                                                  widget.assignPoints!(
                                                      cardData[selectedCard!]
                                                          .assigned,
                                                      cardData[selectedCard!]
                                                          .points!,
                                                      cardData[selectedCard!]
                                                          .id!);
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            buttonColor: Colors.transparent,
                                            borderColor: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText2!
                                                .color,
                                            height: 45,
                                            radius: 45 / 2,
                                            width: responsive(
                                                        width: widget.width) /
                                                    3 -
                                                15,
                                          )
                                        : Container(),
                                    squareButton(
                                      text: 'submit',
                                      onTap: () {
                                        submitCardData();
                                        cardReset();
                                        Navigator.of(context).pop();
                                      },
                                      textColor:
                                          Theme.of(context).indicatorColor,
                                      buttonColor: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText2!
                                          .color!,
                                      height: 45,
                                      radius: 45 / 2,
                                      width: responsive(width: width) / 3 - 10,
                                    )
                                  ])
                            ])
                      : LoadingWheel(),
                ],
              )));
    });
  }

  /// Opens dialog menu for duplicatin cards
  Widget duplicateCard() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 150,
            width: 320,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  Text(
                    "Do you want to duplicate this Task?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText2!.color,
                        fontFamily: 'Klavika',
                        package: 'css',
                        fontSize: 20,
                        decoration: TextDecoration.none),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        squareButton(
                          text: 'cancel',
                          onTap: () {
                            setState(() {
                              boardNameController.text = '';
                            });
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
                          width: 320 / 2 - 10,
                        ),
                        squareButton(
                          text: 'duplicate',
                          onTap: () {
                            isNewCard = true;
                            submitCardData();
                            setState(() {
                              error = false;
                              cardReset();
                            });
                            Navigator.of(context).pop();
                          },
                          textColor: Theme.of(context).indicatorColor,
                          buttonColor: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2!
                              .color!,
                          height: 45,
                          radius: 45 / 2,
                          width: 320 / 2 - 10,
                        )
                      ])
                ]),
          ));
    });
  }

  Widget info(bool drag, String id) {
    return (!drag)
        ? Stack(alignment: AlignmentDirectional.bottomEnd, children: [
            infoContainer(id),
            TaskMasterFloatingActionButton(
                allowed: true,
                color: Theme.of(context).secondaryHeaderColor,
                icon: Icons.add,
                size: 40,
                onTap: () {
                  setState(() {
                    cardReset();
                    boardId = id;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return cardName(null);
                        });
                  });
                }),
          ])
        : infoContainer(id);
  }

  /// Widget that displays all the cards in the board [id]
  Widget infoContainer(String id) {
    List<Widget> cards = [];
    if (cardData.isNotEmpty) {
      for (int index = nextIndex; index < cardData.length; index++) {
        int cardToUse;
        if (cardData[index].boardId == id) {
          cardToUse = index;
          nextIndex = index + 1;
        } else {
          break;
        }
        if (cardBeingDragged != cardData[cardToUse].id) {
          cards.add(InkWell(
              onLongPress: () {
                cardSet(cardToUse).then((value) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        boardId = id;
                        return duplicateCard();
                      });
                });
              },
              onDoubleTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      boardId = id;
                      return cardName(cardToUse);
                    });
              },
              child: dragCard(id, index, cardToUse)));
        } else {
          cards.add(SizedBox(
            height: 70,
            width: boardWidth - 20.0,
          ));
        }
      }
    } else {
      cards.add(Container());
    }
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, right: 10),
      height: height - 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).canvasColor,
      ),
      child: ListView(padding: const EdgeInsets.all(0), children: cards),
    );
  }

  /// Displays title of the board
  Widget title(String title, String subtitle, TextEditingController controller,
      Color color, bool dragged) {
    controller.text = subtitle;
    return Container(
      width: boardWidth,
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
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10),
                child: Text('', //title.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontFamily: 'MuseoSans',
                        package: 'css',
                        decoration: TextDecoration.none))),
            Container(
              width: width,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 10),
              color: Theme.of(context).splashColor,
              child: (!dragged)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          EnterTextFormField(
                            height: 25,
                            width: boardWidth - 65.0,
                            maxLines: 1,
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 10.0),
                            textStyle: TextStyle(
                                color: color,
                                fontFamily: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText2!
                                    .fontFamily,
                                decoration: TextDecoration.none),
                            controller: controller,
                            onEditingComplete: () {
                              if (widget.onTitleChange != null) {
                                widget.onTitleChange!(title, controller.text);
                              }
                            },
                            onSubmitted: (val) {
                              if (widget.onTitleChange != null) {
                                widget.onTitleChange!(title, controller.text);
                              }
                            },
                            onTap: widget.onFocusNode,
                          ),
                          InkWell(
                            onLongPress: () {
                              if (widget.allowEditing && widget.onBoardDelete != null){
                                widget.onBoardDelete!(title);
                              }
                            },
                            child: Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText2!
                                  .color,
                            ),
                          )
                        ])
                  : Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      height: 45,
                      width: width - 20,
                      child: Text(
                        subtitle,
                        style: Theme.of(context).primaryTextTheme.bodyText2,
                      ),
                    ),
            )
          ]),
    );
  }

  /// Widget that displays board when dragging to new position, rotation of board determined by [rotate] and board being used is boardData[i]
  Widget board(int i, bool rotate) {
    return Transform.rotate(
        angle: (rotate) ? 0.174533 : 0,
        child: Container(
          margin: const EdgeInsets.all(10),
          width: boardWidth,
          height: height - 20,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]),
          child: Column(
            children: [
              title(
                boardData[i].id,
                boardData[i].title,
                nameChangeController[i],
                Color(boardData[i].color!),
                rotate
              ),
              info(rotate, boardData[i].id)
            ],
          ),
        ));
  }

  /// Widget that replaces board [i] with container while it is being dragged, also determines behavior of board when dragged
  Widget dragBoard(int i) {
    return Stack(
      children: [
        (boardBeingDragged != boardData[i].id) ? board(i, false) : Container(),
        Draggable(
          data: 0,
          feedback: board(i, true),
          onDragStarted: () {
            setState(() {
              draggedLoc = i;
              boardBeingDragged = boardData[i].id;
            });
          },
          onDragEnd: (val) {
            setState(() {
              boardBeingDragged = '';
              priorityChange();
            });
          },
          onDragCompleted: () {
            setState(() {
              boardBeingDragged = '';
              priorityChange();
            });
          },
          onDraggableCanceled: (vel, off) {
            setState(() {
              boardBeingDragged = '';
              priorityChange();
            });
          },
          child: const Padding(
              padding: EdgeInsets.only(top: 10, left: 10),
              child: Icon(Icons.drag_indicator)),
        ),
      ],
    );
  }

  // Displays the list of boards
  List<Widget> boardList() {
    List<Widget> projects = [];
    nextIndex = 0;
    for (int i = 0; i < boardData.length; i++) {
      nameChangeController.add(TextEditingController());
      if (boardBeingDragged != boardData[i].id) {
        projects.add(InkWell(
            mouseCursor: MouseCursor.defer,
            onDoubleTap: () {
              boardSet(i);
            },
            child: dragBoard(i)));
      } else {
        projects.add(Container(width: boardWidth));
      }
    }
    return projects;
  }

  // Widget that displays dialog to create/update a board
  Widget boardName() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 320 * 3 / 4,
            width: 320,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  Text(
                    "Please Enter the name of the Board!",
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText2!.color,
                        fontFamily: 'Klavika',
                        package: 'css',
                        fontSize: 20,
                        decoration: TextDecoration.none),
                  ),
                  EnterTextFormField(
                    width: 320 - 40.0,
                    height: 35,
                    color: Theme.of(context).canvasColor,
                    maxLines: 1,
                    label: 'Board Name',
                    controller: boardNameController,
                    onEditingComplete: () {},
                    onSubmitted: (val) {},
                    onTap: widget.onFocusNode ?? (){},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Allow Board Notifications!",
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
                      Checkbox(
                          activeColor: Theme.of(context).secondaryHeaderColor,
                          value: allowNofifying,
                          onChanged: (val) {
                            setState(() {
                              allowNofifying = val!;
                            });
                          })
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        squareButton(
                          text: 'cancel',
                          onTap: () {
                            boardReset();
                            Navigator.of(context).pop();
                          },
                          buttonColor: Colors.transparent,
                          borderColor: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2!
                              .color,
                          height: 45,
                          radius: 45 / 2,
                          width: 320 / 2 - 10,
                        ),
                        squareButton(
                          text: (!updateBoard) ? 'submit' : 'update',
                          onTap: () {
                            if (boardNameController.text != '') {
                              if (!updateBoard) {
                                if (widget.onSubmit != null) {
                                  widget.onSubmit!(boardNameController.text,boardData.length, allowNofifying,);
                                }
                              } else {
                                dynamic data = {
                                  'title': boardNameController.text,
                                  'priority': boardData[updateBoardId].priority,
                                  'createdBy':
                                      boardData[updateBoardId].createdBy,
                                  'dateCreated':
                                      boardData[updateBoardId].dateCreated,
                                  'notify': allowNofifying
                                };
                                if (widget.onEdit != null) {
                                  widget.onEdit!(
                                      data, boardData[updateBoardId].id);
                                }
                              }
                              boardReset();
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
                          width: 320 / 2 - 10,
                        )
                      ])
                ]),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.update) {
        setState(() {
          if (widget.callback != null) {
            widget.callback!();
          }
          start();
        });
      }

      if (labelData != widget.labels) {
        setState(() {});

        start();
      }
    });

    return InkWell(
        mouseCursor: MouseCursor.defer,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          (boardData.isNotEmpty)
              ? DragTarget<int>(onMove: (details) {
                  if (details.offset.dx > deviceWidth - 140) {
                    _scrollController.jumpTo(_scrollController.offset + 5);
                  } else if (details.offset.dx < widget.screenOffset.dx + 5 &&
                      _scrollController.offset > 0) {
                    _scrollController.jumpTo(_scrollController.offset - 5);
                  }

                  if (boardBeingDragged != '') {
                    updatePriority(details.offset);
                  }
                  if (cardBeingDragged != '') {
                    updateCardPriority(details.offset);
                  }
                }, builder: (context, List<int?> candidateData, rejectedData) {
                  return Container(
                      height: height,
                      width: width,
                      color: Theme.of(context).canvasColor,
                      child: GestureDetector(
                          onHorizontalDragUpdate: (dragUpdateDetails) {
                            double pos = _scrollController.offset -
                                dragUpdateDetails.delta.dx;
                            _scrollController.jumpTo(pos);
                          },
                          child: ListView(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              scrollDirection: Axis.horizontal,
                              children: boardList())));
                })
              : Container(
                  height: height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                ),
          TaskMasterFloatingActionButton(
              allowed: widget.allowEditing,
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icons.add,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return boardName();
                    });
              }),
        ]));
  }
}
