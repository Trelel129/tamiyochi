import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tamiyochi/page/forum/forum_detail_page.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<String> forumData;
  final BuildContext context;
  Map<String, String> titleToForumIdMap = {};

  CustomSearchDelegate(this.context, this.forumData) {
    fetchTitleToForumIdMap();
  }

  Future<void> fetchTitleToForumIdMap() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('forum').get();
    querySnapshot.docs.forEach((doc) {
      titleToForumIdMap[doc['title']] = doc.id;
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? forumData
        : forumData
            .where((title) => title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final title = suggestionList[index];
        return ListTile(
          title: Text(title),
          onTap: () {
            final forumId = getForumIdByTitle(title);
            if (forumId != null) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ForumDetailPage(
                  forumId: forumId,
                  title: title,
                  image: '',
                  email: '',
                ),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Forum ID not found for $title')),
              );
            }
          },
        );
      },
    );
  }

  String? getForumIdByTitle(String title) {
    return titleToForumIdMap[title];
  }
}
