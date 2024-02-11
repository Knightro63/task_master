<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Task Master

Use this package to implement a task management system in your Flutter application.

![Picture of the task manager UI](https://github.com/Knightro63/task_master/blob/main/docs/Task%20Manager.png)

# Features

[* See implementation in example app *](https://github.com/Knightro63/task_master/blob/main/example/README.md)

Projects:
- Create Boards to keep track of progress 
- Mark a project as complete
- Add due date

![Picture of the task manager UI](https://github.com/Knightro63/task_master/blob/main/docs/Project%20Creation.gif)

Boards:
- Drag boards to change their order
- Drag cards in between boards to track progress

![Picture of the task manager UI](https://github.com/Knightro63/task_master/blob/main/docs/Board%20Drag.gif)

Task Cards:
- Add due dates
- Create a checklist
- Leave comments
- Assign Users
- Add Editors
- Incentivize with points
- Change priority

![Picture of the task manager UI](https://github.com/Knightro63/task_master/blob/main/docs/Task%20Completion.gif)

# Getting started

To get started with taskmaster add the package to your pubspec.yaml file.

# Usage

Taskmaster is able to operate statically by default with data that you provide through its parameters. There are two parts a BoardManager and ProjectManager.

The BoardManager will specialize in the logic and display of the boards and cards. 
The ProjectManager will specialize in the logic and display of the project cards.

To enable dynamic updates of the task manager data and upload to database, you must pass in callback functions through the parameters provided in the package.

## Board Manager

- Drag boards across the view to re-order them
- Add or remove cards when provided with callback functions
- Change color and name of board titles
- Provide database callbacks to dynamically update board

Example of a function to pass to BoardManager to push new board to database (Firebase Realtime Database):
\* Database class is defined in the package/example

```dart
onSubmit: (title, priority, notify) async {
    DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
    String date = dayFormatter
        .format(DateTime.now())
        .replaceAll(' ', 'T');

    Database.push(children: '$child/boards', data: {
    'createdBy': widget.currentUID,
    'dateCreated': date,
    'title': title,
    'priority': priority,
    'notify': notify
    });

    setState(() {});
},
```

## Project Manager

- Create, delete and update projects using the 'plus' button
- View, edit and create labels to use for the project tasks
- Define behavior for project completion
- Supports addition of point system when provided with callbacks
- Provide database callbacks to dynamically update projects

Example of a function to pass to ProjectManager to push new board to database (Firebase Realtime Database):
\* Database class is defined in the package/example

```dart
onSubmit: (title, image, date, color) async {
    DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
    String createdDate =
        dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');

    Database.push(children: '$child/', data: {
        'department': currentEpic,
        'createdBy': "example",
        'dateCreated': createdDate,
        'dueDate': (date != '') ? date : null,
        'title': title,
        'image': (image == ' ') ? 'temp' : image,
        'color': color,
    });
},
```

## JSON of an epic with 1 project, assigned 1 board, with 1 card in that board (see example app for implementation)
```json
{
    "Epic": {
        "epic-id": {
            "project-id 1": {
                "boards": {
                    "board 1 id": {
                        "createdBy": "",
                        "dateCreated": "YYYY-MM-DDT00:00:00",
                        "notify": false,
                        "priority": 0,
                        "title": ""
                    }
                },
                "cards": {
                    "card 1 id": {
                        "board": "board1 Key",
                        "data": {
                            "assigned": [],
                            "createdBy": "",
                            "createdDate": "YYYY-MM-DDT00:00:00",
                            "editors": [],
                            "labels": [],
                            "points": 0,
                            "title": ""
                        },
                        "priority": 0,
                        "project": "Project 1 key"
                    }
                },
                "color": 0,
                "completed": {
                    "date": "YYYY-MM-DDT00:00:00",
                    "department": ""
                },
                "createdBy": "",
                "dateCreated": "YYYY-MM-DDT00:00:00",
                "department": "",
                "dueDate": "YYYY-MM-DDT00:00:00",
                "image": "",
                "title": ""
            }
        }
    },

    "Label": {
        "epic-id": {
            "label-id": {
                "color": 123,
                "name": "Label Name"
            }
        }
    },

    "Users": {
        "user-uid": {
            "credentials": "",
            "displayName": "Name",
            "imageUrl": "imageUrl",
            "uid": "user-uid"
        }
    },

    "complete": {
        "epic-id": {
            "project-id": {
                "card-id": {
                    "compeletedDate": "YYYY-MM-DDT00:00:00",
                    "title": "example card 1"
                }
            }
        }
    },

    "points": {
        "epic-id": {
            "user-uid": {
                "project-uid": {
                    "card-uid": {
                        "assignedBy": "uid",
                        "dateAssigned": "YYYY-MM-DDT00:00:00",
                        "points": 50
                    }
                }
            }
        }
    }
}
```

## Example

Find the example for this package [here](https://github.com/Knightro63/task_master/tree/main/example/lib/main.dart)

## Contributing

Contributions are welcome. In case of any problems look at [existing issues](https://github.com/Knightro63/task_master/issues), if you cannot find anything related to your problem then open an issue. Create an issue before opening a [pull request](https://github.com/Knightro63/task_master/pulls) for non trivial fixes. In case of trivial fixes open a [pull request](https://github.com/Knightro63/task_master/pulls) directly.


