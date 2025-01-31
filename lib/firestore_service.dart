import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latestlnf/posting/report_lost_item.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _reportsCollection = _firestore.collection('report');

Future<void> uploadReport(ReportLostItemPage report) async {
  await _reportsCollection.add(report.toMap());
}

Future<List> getReports() async {
  QuerySnapshot querySnapshot = await _reportsCollection.get();
  return querySnapshot.docs
      .map((doc) => ReportLostItemPage.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}