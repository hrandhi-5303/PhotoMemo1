import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/Notification_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/notification_model.dart';
import 'package:lesson3/model/photo_comment.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

import '../model/photo_memo.dart';

class CommentScreen extends StatefulWidget {
  static const routeName = "/comment_screen";
  final User user;
  final PhotoMemo photoMemo;

  final List<PhotoComment> photoComment;
  const CommentScreen(
      {required this.user,
      required this.photoMemo,
      required this.photoComment,
      Key? key})
      : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late _Controller controller;
  final formKey = GlobalKey<FormState>();
  final newFormKey = GlobalKey<FormState>();
  List<bool> editMode = [];
  TextEditingController comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
    editMode = List<bool>.filled(widget.photoComment.length, false);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Comments"),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(),
                        Container(
                          width: MediaQuery.of(context).size.width - 80,
                          child: TextFormField(
                            decoration: const InputDecoration(
                                hintText: 'Add your comments here',
                                border: InputBorder.none),
                            keyboardType: TextInputType.text,
                            autocorrect: false,

                            validator: controller.validateComment,
                            onSaved: controller.saveComment,
                            // onChanged: (val) {
                            //   controller.saveComment(val);
                            // },
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            controller.addComment();
                          },
                          child: Icon(Icons.send,
                              color: Color.fromARGB(255, 38, 133, 210)),
                        ),
                        Container(),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.blue,
                    thickness: 2,
                  )
                ],
              ),
              controller.photoCommentList.isEmpty
                  ? Text(
                      'No PhotoMemoComment Found!',
                      style: Theme.of(context).textTheme.headline6,
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: controller.photoCommentList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  trailing: controller.state.widget.user.uid ==
                                          controller
                                              .photoCommentList[index].authorID
                                      ? IntrinsicWidth(
                                          child: Row(
                                            children: [
                                              editMode[index] == false
                                                  ? GestureDetector(
                                                      onTap: () => controller
                                                          .delete(controller
                                                              .state
                                                              .widget
                                                              .photoComment[
                                                                  index]
                                                              .commentID),
                                                      child: Icon(Icons.delete))
                                                  : IconButton(
                                                      onPressed: () {
                                                        controller
                                                            .editCancle(index);
                                                      },
                                                      icon: Icon(Icons.cancel,
                                                          color: Color.fromARGB(
                                                              255,
                                                              38,
                                                              133,
                                                              210)),
                                                    ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              editMode[index] == true
                                                  ? IconButton(
                                                      onPressed: () {
                                                        controller.editComment(
                                                            controller
                                                                .state
                                                                .widget
                                                                .photoComment[
                                                                    index]
                                                                .commentID,
                                                            index);
                                                      },
                                                      icon: Icon(Icons.send,
                                                          color: Color.fromARGB(
                                                              255,
                                                              38,
                                                              133,
                                                              210)),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        controller.edit(index);
                                                      },
                                                      child: Icon(Icons.edit))
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 1,
                                          width: 1,
                                        ),
                                  title: editMode[index] == true
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          child: Form(
                                            key: newFormKey,
                                            child: TextFormField(
                                              initialValue: controller
                                                  .photoCommentList[index]
                                                  .commentText,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Add your comments here',
                                                  border: InputBorder.none),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autocorrect: false,
                                              validator:
                                                  controller.validateNewComment,
                                              onSaved:
                                                  controller.saveNewComment,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(controller
                                                .photoCommentList[index]
                                                .createdBy),
                                            Text(controller
                                                .photoCommentList[index]
                                                .commentText),
                                          ],
                                        ),
                                ),
                                const Divider(
                                  color: Colors.black,
                                  indent: 20,
                                  endIndent: 20,
                                )
                              ],
                            );
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  // _CommentScreenState state;
  // late PhotoComment photoComment;
  // late PhotoMemo tempMemo;
  // late List<PhotoComment> photoCommentList;

  // _Controller(this.state) {
  //   tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  //   photoCommentList = state.widget.photoComment;
  //   for (int i = 0; i < state.widget.photoComment.length; i++) {
  //     photoComment = PhotoComment.clone(state.widget.photoComment[i]);
  //   }
  // }

  _CommentScreenState state;
  PhotoComment photoComment = PhotoComment();
  late PhotoMemo tempMemo;
  late List<PhotoComment> photoCommentList;

  _Controller(this.state) {
    photoComment = PhotoComment.clone(photoComment);
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
    photoCommentList = state.widget.photoComment;
  }
  String? comment = '';

  String? validateComment(String? value) {
    if (value!.isEmpty) {
      print('No comment provided');
      return 'No comment provided';
    } else {
      return null;
    }
  }

  String? validateNewComment(String? value) {
    if (value!.isEmpty) {
      print('No comment provided');
      return 'No comment provided';
    } else {
      return null;
    }
  }

  void saveNewComment(String? value) {
    if (value != null) {
      comment = value;
    }
  }

  void editComment(String commentId, int index) async {
    FormState? currentState = state.newFormKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();
    try {
      startCircularProgress(state.context);
      if (comment != photoCommentList[index].commentText) {
        await FirestoreController.updateComment(
            docId: commentId, newComment: comment!);
        photoCommentList[index].commentText = comment!;
      }

      stopCircularProgress(state.context);
      // state.widget.photoMemo.copyFrom(tempMemo);
      state.render(() =>
          state.widget.photoComment[index].copyFrom(photoCommentList[index]));
      editCancle(index);
    } catch (e) {}
  }

  void edit(int index) {
    state.render(() => state.editMode[index] = true);
  }

  void editCancle(int index) {
    state.render(() => state.editMode[index] = false);
  }

  void saveComment(String? value) {
    if (value != null) {
      comment = value;
    }
  }

  void delete(String id) async {
    num newCount = state.widget.photoMemo.commentCount;
    startCircularProgress(state.context);

    try {
      await FirestoreController.deleteComment(docId: id);

      state.render(() {
        photoCommentList.removeWhere((element) => element.commentID == id);
      });
      photoComment.postID = state.widget.photoMemo.postId;
      newCount = newCount - 1;
      await FirestoreController.updatePhotoMemoCommentCount(
          photoMemoDocId: photoComment.postID, totalCount: newCount);
      print(newCount);
      tempMemo.commentCount = newCount;

      state.render(() {
        state.widget.photoMemo.commentCopy(tempMemo.commentCount);
      });

      stopCircularProgress(state.context);
      // state.widget.photoMemo.copyFrom(tempMemo);

    } catch (e) {
      stopCircularProgress(state.context);
    }
  }

  void addComment() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    try {
      startCircularProgress(state.context);
      num newCount = state.widget.photoMemo.commentCount;

      photoComment.authorID = state.widget.user.uid;
      photoComment.createdBy = state.widget.user.email!;
      photoComment.commentText = comment!;
      photoComment.createdAt = Timestamp.now();
      photoComment.postID = state.widget.photoMemo.postId;
      print(state.widget.photoMemo.postId);
      print(state.widget.photoMemo.commentCount);
      String commenId = await FirestoreController.addCommentToPhotoMemo(
          photoComment: photoComment);


      await FirestoreController.updatePhotoMemoCommentID(
          photoMemoCommentId: commenId);
      newCount = newCount + 1;
      print(newCount);
      await FirestoreController.updatePhotoMemoCommentCount(
          photoMemoDocId: photoComment.postID, totalCount: newCount);
      tempMemo.commentCount = newCount;
      state.render(() {
        state.widget.photoMemo.commentCopy(tempMemo.commentCount);
      });
      // state.widget.photoMemo.copyFrom(tempMemo);
      //photoComment.copyFrom(photoComment);
      Navigator.pop(state.context);

      NotificationModel notificationModel=NotificationModel(
        title: "Memo",
        body: "${FirebaseAuth.instance.currentUser!.email} commented on your photo",
        sentTo:  state.widget.photoMemo.createdBy ,
        sentBy: FirebaseAuth.instance.currentUser!.email
      );
      await NotificationController().sendNotification(notificationModel);
      for(var sharedWith in  state.widget.photoMemo.sharedWith){
        NotificationModel notificationModel=NotificationModel(
            title: "Memo",
            body: "${FirebaseAuth.instance.currentUser!.email} commented on photo shared with you",
            sentTo: sharedWith,
            sentBy: FirebaseAuth.instance.currentUser!.email
        );
        await NotificationController().sendNotification(notificationModel);
      }

      stopCircularProgress(state.context);
      //Navigator.pop(state.context);
    } catch (e) {
      stopCircularProgress(state.context);
    }
  }
}
