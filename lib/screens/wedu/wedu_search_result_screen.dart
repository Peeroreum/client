import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:peeroreum_client/designs/PeeroreumColor.dart';

import '../../api/PeeroreumApi.dart';
import '../../data/WeduSearchHistory.dart';

class SearchResultWedu extends StatefulWidget {
  final String keyword;
  SearchResultWedu(this.keyword);

  @override
  State<SearchResultWedu> createState() => _SearchResultWeduState(keyword);
}

class _SearchResultWeduState extends State<SearchResultWedu> {
  var token;

  String keyword;
  _SearchResultWeduState(this.keyword);

  List<Map<String, String>> _searchHistory = [];
  List<dynamic> datas = [];
  List<dynamic> inviDatas = [];
  List<dynamic> hashTags = [];
  List<String> gradeList = ['전체', '중1', '중2', '중3', '고1', '고2', '고3'];
  List<String> subjectList = ['전체', '국어', '영어', '수학', '사회', '과학', '기타'];

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async {
    token = await FlutterSecureStorage().read(key: "accessToken");
    var weduResult = await http.get(
        Uri.parse('${API.hostConnect}/wedu/search/${keyword}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
    if (weduResult.statusCode == 200) {
      datas = jsonDecode(utf8.decode(weduResult.bodyBytes))['data'];
      print("데이터 fetch 완료 \n $datas");
    } else {
      print("에러${weduResult.statusCode}");
    }

    await fetchImage(datas);
  }

  fetchImage(datas) async {
    var inviData;
    for(var data in datas) {
      inviData = await fetchInvitation(data['id']);
      print(inviData);
      inviDatas.add(inviData);
      hashTags.add(inviData['hashTags']);
    }
  }

  fetchInvitation(id) async {
    var inviResult = await http.get(
        Uri.parse('${API.hostConnect}/wedu/$id/invitation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (inviResult.statusCode == 200) {
      return await jsonDecode(utf8.decode(inviResult.bodyBytes))['data'];
    } else {
      print("에러${inviResult.statusCode}");
    }
  }

  _loadSearchHistory() async {
    _searchHistory = await SearchHistory.getSearchHistory();
    setState(() {});
  }

  _saveSearchHistory(String value) async {
    await SearchHistory.addSearchItem(value);
    _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = keyword;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/arrow-left.svg',
                color: PeeroreumColor.gray[800],
              ),
              onPressed: () {
                Navigator.of(context).pop(_searchHistory);
              },
            ),
            titleSpacing: 0,
            title: Padding(
              padding: EdgeInsets.fromLTRB(0, 12, 20, 12),
              child: SearchBar(
                // padding: MaterialStateProperty.all(
                //     EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
                controller: textEditingController,
                backgroundColor:
                MaterialStateProperty.all(PeeroreumColor.gray[100]),
                elevation: MaterialStateProperty.all(0),
                // shape: MaterialStateProperty.all(ContinuousRectangleBorder(
                //     borderRadius: BorderRadius.all(Radius.circular(37.0)))),
                constraints: BoxConstraints(maxHeight: 40),
                hintText: '같이방에서 함께 공부해요!',
                hintStyle: MaterialStateProperty.all(TextStyle(
                    color: PeeroreumColor.gray[600],
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
                trailing: [
                  GestureDetector(
                      onTap: () {
                        textEditingController.clear();
                      } ,
                      child: SvgPicture.asset(
                        'assets/icons/x_circle.svg',
                        color: PeeroreumColor.gray[600],
                      )
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        keyword = textEditingController.text;
                        fetchDatas();
                        _saveSearchHistory(keyword);
                      });
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/search.svg',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
        ),
        body: FutureBuilder<void>(
          future: fetchDatas(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if(snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            '검색된 같이방',
                            style: TextStyle(
                                color: PeeroreumColor.gray[800],
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(width: 4,),
                          Text(
                            '${datas.length}',
                            style: TextStyle(
                                color: PeeroreumColor.gray[800],
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                    listview_body()
                  ],
                ),
              );
            }
          },
        )
      ),
    );
  }

  Widget listview_body() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: datas.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 8,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: PeeroreumColor.gray[200]!),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: PeeroreumColor.gray[200]!),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: (datas[index]["imagePath"] != null)? Image.network(datas[index]["imagePath"]!,
                      width: 44, height: 44) : Image.asset('assets/images/example_logo.png', width: 44, height: 44),
                ),
                Container(
                  height: 44,
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor
                                    .subjectColor[subjectList[datas[index]['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  subjectList[datas[index]['subject']],
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    color: PeeroreumColor
                                        .subjectColor[subjectList[datas[index]['subject']]]?[1],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              datas[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(gradeList[datas[index]["grade"]],
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('${datas[index]["attendingPeopleNum"]!}명 참여중',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⋅'),
                            ),
                            Text('D-${datas[index]["dday"]!}',
                                style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PeeroreumColor.gray[600])),
                          ],
                        )
                      ]),
                )
              ],
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              isScrollControlled: true,
              builder: (context) {
                return roominfo(index);
              },
            );
          },
        );
      },
    );
  }

  Widget roominfo(index) {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.55,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8)
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: PeeroreumColor.gray[200]!),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0))),
                        child: Image.network(datas[index]["imagePath"]!,
                            width: 72, height: 72),
                      ),
                      Container(
                        height: 72,
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                                color: PeeroreumColor.subjectColor[subjectList[datas[index]['subject']]]?[0],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Text(
                                  subjectList[datas[index]["subject"]],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: PeeroreumColor.subjectColor[subjectList[datas[index]['subject']]]?[1],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              datas[index]["title"]!,
                              style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: PeeroreumColor.black),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Text(gradeList[datas[index]["grade"]],
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text('⋅'),
                                ),
                                Text('${datas[index]["attendingPeopleNum"]!}명 참여중',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text('⋅'),
                                ),
                                Text('D-${datas[index]["dday"]!}',
                                    style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: PeeroreumColor.gray[600])),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: PeeroreumColor.gray[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/share.svg',
                      ),
                    ),
                  )
                ],
              ),
              roominfo_tag(index),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  inviDatas[index]['challenge'],
                  style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                decoration: BoxDecoration(
                    color: PeeroreumColor.gray[50],
                    borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 162,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(inviDatas[index]['invitationUrl']),
                        fit: BoxFit.cover
                    ),
                    color: PeeroreumColor.primaryPuple[400],
                    borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.gray[600],
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(PeeroreumColor.gray[300]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    enrollWedu(index);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '참여하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PeeroreumColor.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        PeeroreumColor.primaryPuple[400]),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget roominfo_tag(roomIndex) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: PeeroreumColor.primaryPuple[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(100.0))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '#',
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[200],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      hashTags[roomIndex][index],
                      style: TextStyle(
                        color: PeeroreumColor.primaryPuple[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 4,
              );
            },
            itemCount: hashTags[roomIndex].length
        ),
      ),
    );
  }

  void enrollWedu(index) async {
    var id = datas[index]['id'];
    var enrollResult = await http
        .post(Uri.parse('${API.hostConnect}/wedu/$id/enroll'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
    if(enrollResult.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "같이방 참여 완료!"
      );
    } else if(enrollResult.statusCode == 409) {
      Fluttertoast.showToast(msg: '이미 참여 중인 같이방입니다.');
    } else {
      Fluttertoast.showToast(msg: '잠시 후에 다시 시도해 주세요.');
      print('에러${enrollResult.statusCode}${enrollResult.body}');
    }
  }
}