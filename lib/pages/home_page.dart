import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FireStoreService firestoreService = FireStoreService();

  //text controller
  final TextEditingController textcontroller = TextEditingController();

  //open a box to add a note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textcontroller,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        firestoreService.addNote(textcontroller.text);
                      }
                      else{
                        firestoreService.updateNote(docID, textcontroller.text);
                      }

                      //clear the text controller
                      textcontroller.clear();

                      //close the box
                      Navigator.pop(context);
                    },
                    child: Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            'Notes',
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.blue,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNotesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List notesList = snapshot.data!.docs;

                //return as a list
                return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;

                    //get note from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tile
                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: Icon(Icons.drive_file_rename_outline)),

                          IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: Icon(Icons.delete)),
                        ],
                      )
                    );
                  },
                );
              } else {
                return const Text('No notes...');
              }
            }));
  }
}
