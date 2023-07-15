import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/NewfeedModel.dart';
import 'package:myapp/src/resources/user/detail_post.dart';

class SearchPostScreen extends StatefulWidget {
  const SearchPostScreen({Key? key}) : super(key: key);

  @override
  State<SearchPostScreen> createState() => _SearchPostScreenState();
}

class _SearchPostScreenState extends State<SearchPostScreen> {
  List searchResult = [];
  String name = '';
  NewfeedModel newFeedModel = NewfeedModel();

  Future<void> searchPost(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('newfeed')
        .where('content', isEqualTo: query)
        .get();

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  
                  hintText: 'Search here...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  suffixIcon: Icon(Icons.search_rounded, color: Colors.grey,)
                ),
                onChanged: (val) {
                  setState(() {
                    name = val;
                  });
                },
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                  FirebaseFirestore.instance.collection('newfeed').snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : ListView.builder(
                      key: UniqueKey(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                          if (name.isEmpty) {
                            return const SizedBox();
                          }
                          if (data['content']
                              .toString()
                              .toLowerCase()
                              .startsWith(name.toLowerCase())) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  newFeedModel.id = data['id']!;
                                  newFeedModel.file = data['file']!;
                                  newFeedModel.content = data['content']!;
                                  newFeedModel.time = data['time']!;
                                  newFeedModel.employeeId = data['employeeId']!;
                                });
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPostScreen(newFeedModel: newFeedModel,)));
                              },
                              child: ListTile(
                                subtitle: Text(data['time']),
                                title: Text(
                                  data['content'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        });
                  },
                ))
          ],
        ),
      ),
    );
  }
}
