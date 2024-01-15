import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../designs/PeeroreumColor.dart';

class EncouragementList extends StatefulWidget {
  @override
  State<EncouragementList> createState() => _EncouragementListState();
}

class _EncouragementListState extends State<EncouragementList> {
  List<dynamic> notSuccessList = [];
  @override
  Widget build(BuildContext context) {
    notSuccessList =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return Scaffold(
        backgroundColor: PeeroreumColor.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: PeeroreumColor.white,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/x.svg',
              color: PeeroreumColor.gray[800],
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '미달성',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: PeeroreumColor.black),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/icon_dots_mono.svg',
                  color: PeeroreumColor.gray[800],
                ))
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical:13, horizontal:20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '전체',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: PeeroreumColor.gray[500]),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${notSuccessList.length}',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: PeeroreumColor.gray[500]),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '명',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: PeeroreumColor.gray[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: PeeroreumColor.gray[100],
                thickness: 1,
                height: 8,
              ),
              notOkList()
            ],
          ),
        ),
        );
  }

  notOkList() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 140,
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 2,
                            color: PeeroreumColor
                                .gradeColor[notSuccessList[index]['grade']]!),
                      ),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: PeeroreumColor.white,
                          ),
                          image: notSuccessList[index]["profileImage"] != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                      notSuccessList[index]["profileImage"]),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: AssetImage('assets/images/user.jpg')),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      notSuccessList[index]['nickname'],
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: PeeroreumColor.gray[800]),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(
                  color: PeeroreumColor.gray[100],
                  thickness: 1,
                  height: 8,
                ),
            itemCount: notSuccessList.length));
  }
}
