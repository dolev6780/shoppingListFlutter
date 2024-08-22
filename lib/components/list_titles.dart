import 'package:flutter/material.dart';
import 'package:shoppinglist/components/list_card.dart';
import 'package:shoppinglist/components/pending_list_card.dart';
import 'package:shoppinglist/services/data_service.dart';

class ListTitles extends StatefulWidget {
  final Future<void> Function() refreshLists;

  const ListTitles({Key? key, required this.refreshLists}) : super(key: key);

  @override
  ListTitlesState createState() => ListTitlesState();
}

class ListTitlesState extends State<ListTitles> {
  final DataService dataService = DataService();

  Future<void> handlePendingList(
      bool approved, String docId, Map<String, dynamic> item) async {
    if (approved) {
      await dataService.approvePendingList(item, docId);
      widget.refreshLists();
    } else {
      await dataService.deletePendingList(docId);
      widget.refreshLists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        dataService.fetchPendingListTitles(),
        dataService.fetchListTitles(),
      ]),
      builder: (BuildContext context,
          AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "לחץ על רשימה חדשה בשביל ליצור רשימת קניות",
          );
        } else {
          final pendingListTitles = snapshot.data![0];
          final listTitles = snapshot.data![1];

          final combinedList = <Map<String, dynamic>>[];

          if (pendingListTitles.isNotEmpty) {
            combinedList.addAll(pendingListTitles);
          }
          combinedList.addAll(listTitles);
          return ListView.builder(
              itemCount: combinedList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = combinedList[index];
                if (item['type'] == 'pending') {
                  return PendingListCard(
                    item: item,
                    handlePendingList: handlePendingList,
                    dataService: dataService,
                  );
                }
                if (item['finished'] != true) {
                  return ListCard(
                    item: item,
                    refreshLists: widget.refreshLists,
                    dataService: dataService,
                  );
                }
              });
        }
      },
    );
  }
}
