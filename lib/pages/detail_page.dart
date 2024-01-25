import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_workshop/components/status_dialog.dart';
import 'package:lapor_workshop/components/styles.dart';
import 'package:lapor_workshop/models/akun.dart';
import 'package:lapor_workshop/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;

  String? status;
  TextEditingController commentController = TextEditingController();

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/istock-default.jpg'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Ubah Status'),
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 250,
                        child: ElevatedButton(
                          child: Text('Tambah Komentar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      backgroundColor: primaryColor,
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              laporan.judul,
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            TextField(
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: 7,
                                              controller: commentController,
                                              decoration: const InputDecoration(
                                                hintText: 'Tambah Komentar',
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 3,
                                                            color:
                                                                Colors.black)),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () async {
                                                addComment(laporan.docId);
                                                Navigator.pushReplacementNamed(
                                                    context, '/detail',
                                                    arguments: {
                                                      'laporan': laporan,
                                                      'akun': akun,
                                                    });
                                                // Navigator.popAndPushNamed(context, '/detail');
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text('Poting Komentar'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                          },
                        ),
                      ),

                      // Container(
                      //   width: 250,
                      //   child: ElevatedButton(
                      //     child: Text('Tambah Komentar'),
                      //     style: TextButton.styleFrom(
                      //       foregroundColor: Colors.white,
                      //       backgroundColor: primaryColor,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       showDialog(
                      //           context: context,
                      //           builder: (context) => AlertDialog(
                      //             backgroundColor: primaryColor,
                      //                 title: Text(laporan.judul),
                      //                 content: TextField(
                      //                   keyboardType:
                      //                             TextInputType.multiline,
                      //                         maxLines: 7,
                      //                   controller: commentController,
                      //                   decoration: const InputDecoration(
                      //                       hintText: 'Tambah Komentar',
                      //                        focusedBorder:
                      //                                 OutlineInputBorder(
                      //                                     borderSide: BorderSide(
                      //                                         width: 3,
                      //                                         color: Colors.black
                      //                                             )),
                      //                             ),
                      //                 ),
                      //                 actions: [
                      //                   IconButton(
                      //                     icon: const Icon(Icons.send),
                      //                     onPressed: () async {
                      //                       setState(() {
                      //                         addComment(laporan.docId);
                      //                       });
                      //                     },
                      //                   ),
                      //                 ],
                      //               ));
                      //     },
                      //   ),
                      // ),

                      //belum kelar
                      // Container(
                      //   width: 250,
                      //   child: ElevatedButton(
                      //     child: Text('Tambah Komentar'),
                      //     style: TextButton.styleFrom(
                      //       foregroundColor: Colors.white,
                      //       backgroundColor: primaryColor,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       showDialog(
                      //           context: context,
                      //           builder: (context) => AlertDialog(
                      //                 backgroundColor: primaryColor,
                      //                 title: Text(laporan.judul),
                      //                 content: Container(
                      //                   width:
                      //                       MediaQuery.of(context).size.width *
                      //                           0.8,
                      //                   padding:
                      //                       EdgeInsets.symmetric(vertical: 10),
                      //                   decoration: BoxDecoration(
                      //                     color: Colors.white,
                      //                     borderRadius:
                      //                         BorderRadius.circular(10),
                      //                   ),
                      //                   child: Column(
                      //                     mainAxisSize: MainAxisSize.min,
                      //                     children: <Widget>[
                      //                       Text(laporan.judul)
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 // actions: [
                      //                 //   IconButton(
                      //                 //     icon: const Icon(Icons.send),
                      //                 //     onPressed: () async {
                      //                 //       setState(() {
                      //                 //         addComment(laporan.docId);
                      //                 //       });
                      //                 //     },
                      //                 //   ),
                      //                 // ],
                      //               ));
                      //     },
                      //   ),
                      // ),

                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: ElevatedButton(
                      //         child: Text('Tambah Komentar'),
                      //         style: TextButton.styleFrom(
                      //           foregroundColor: Colors.white,
                      //           backgroundColor: primaryColor,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //         onPressed: () {
                      //           showDialog(
                      //               context: context,
                      //               builder: (context) => AlertDialog(
                      //                     title: Text(laporan.judul),
                      //                     content: TextField(
                      //                       controller: commentController,
                      //                       decoration: const InputDecoration(

                      //                           hintText: 'Tambah Komentar'),
                      //                     ),
                      //                     actions: [
                      //                       IconButton(
                      //                         icon: const Icon(Icons.send),
                      //                         onPressed: () async {
                      //                           setState(() {
                      //                             addComment(laporan.docId);
                      //                           });
                      //                         },
                      //                       ),
                      //                     ],
                      //                   ));
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Komentar',
                            style: headerStyle(level: 3),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Komentar>>(
                            future: getCommentsData(laporan.docId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Text('Tidak ada komentar.');
                              } else {
                                // Menampilkan daftar komentar
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    Komentar comment = snapshot.data![index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        // Tambahkan gambar profil atau ikon profil sesuai dengan data comment

                                        backgroundImage: comment
                                                .profile.isNotEmpty
                                            ? NetworkImage(comment.profile)
                                            : AssetImage(
                                                    'assets/images/emperor.jpg')
                                                as ImageProvider,

                                        // Atau jika Anda memiliki ikon profil, bisa gunakan seperti ini:
                                        // child: Icon(Icons.account_circle),
                                      ),
                                      title: Text(comment.nama),
                                      subtitle: Text(comment.isi),
                                      trailing: Text(
                                        DateFormat('dd MMM yyyy HH:mm')
                                            .format(comment.waktu),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }

  Future<void> addComment(String docId) async {
    try {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      Akun akun = arguments['akun'];
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');

      String commentText = commentController.text.trim();

      // Membuat ID unik untuk setiap komentar
      String commentId = DateTime.now().toIso8601String() +
          Random().nextInt(10000000).toString();

      await laporanCollection
          .doc(docId)
          .collection('comments')
          .doc(commentId)
          .set({
        'uid_akun': akun.uid,
        'profile': akun.profile,
        'nama': akun.nama,
        'comment': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil ditambahkan'),
        ),
      );

      commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Gagal menambahkan komentar.'),
        ),
      );
    }
  }

  Future<List<Komentar>> getCommentsData(String docId) async {
    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('laporan')
          .doc(docId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      // Dapatkan data komentar
      List<Komentar> comments = commentSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Komentar(
          profile: data['profile'] ?? '',
          nama: data['nama'] ?? '',
          isi: data['comment'] ?? '',
          waktu: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      return comments;
    } catch (e) {
      print('Error getting comments data: $e');
      return [];
    }
  }
}
