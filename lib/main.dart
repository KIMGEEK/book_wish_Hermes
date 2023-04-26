import 'package:flutter/material.dart';
import 'style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:requests/requests.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Store(),
      child: MaterialApp(
        theme: style.theme,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /*도서 신청 Request 사용*/
  bookQueryRequestV() async {
    var uri = 'http://www.kyoboacademy.co.kr/lipss/wishbook/index.laf?';
    var data = {'libCd': '00138'};
    var r = await Requests.post(uri, body: data);
    print(r.statusCode);
    var headers = {
      "Accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    };
    var URL =
        "http://www.kyoboacademy.co.kr/wsclient/requestWishbook.laf?libCd=00138&univCd=11409&ipid=2080617575&patronAid=&wishMemNo=&wishMemId=&wishMemNm=%B9%E9%C7%CF%C1%D8&email=baekhajun%40cbnu.ac.kr&memType=STU&solNm=STU&dupStatusNm=&ACADEMYSESSIONID=vQhJS2sGsR1dHg0BQqX8HsFzsRvL7QMTHsQqnCYnhH9lHJp21wdX!1089767593;&comment=&barcode=9791162245736&ejkGb=KOR&chkproc=0";
    var page = await Requests.get(URL, headers: headers);
    print(page.statusCode);
  }

  bookQueryHttpV() async {
    Map<String, String> headers = {};
    var URI = 'http://www.kyoboacademy.co.kr/lipss/wishbook/index.laf?';
    var result = await http.post(Uri.parse(URI), body: {"libCd": "00138"});

    if (result.headers['set-cookie'].runtimeType == String) {
      headers['cookie'] = result.headers['set-cookie'].toString();
    }
    print(headers['cookie']);
    var URL = Uri.parse(
        "http://www.kyoboacademy.co.kr/wsclient/requestWishbook.laf?libCd=00138&univCd=11409&ipid=2080617575&patronAid=&wishMemNo=&wishMemId=&wishMemNm=%B9%E9%C7%CF%C1%D8&email=baekhajun%40cbnu.ac.kr&memType=STU&solNm=STU&comment=&barcode=9791162245736&ejkGb=KOR&chkproc=0");
    var result1 = await http.get(URL, headers: headers);
    if (result1.statusCode == 200) {
      print('도서 성공: ${result1.statusCode}');
    } else {
      throw Exception('도서 실패: ${result1.statusCode}');
    }
  }

  var bookTitle;
  var searchData = TextEditingController();
  addData(a) {
    setState(() {
      bookTitle = a;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(Icons.book),
        actions: [Icon(Icons.menu)],
        leading: Icon(Icons.account_circle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/Hermes_logo.png', width: 300),
          Center(
            child: SizedBox(
              width: 800.0,
              child: TextField(
                controller: searchData,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1.0),
                        borderRadius: BorderRadius.circular(30)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: '조회할 도서를 입력하세요.'),
              ),
            ),
          ),
          TextButton(
            child: Text('다음'),
            onPressed: () {
              addData(searchData.text);
              print(bookTitle);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => BookList(bookTitle: bookTitle))));
            },
          ),
        ],
      ),
    );
  }
}

class BookList extends StatefulWidget {
  BookList({Key? key, this.bookTitle}) : super(key: key);
  final bookTitle;

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  var data;
  var header = {
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  };
  @override
  void initState() {
    super.initState();
    data = {
      'ttbkey': 'ttbmlboy101516001',
      'Query': widget.bookTitle,
      'QueryType': 'Title',
      'MaxResults': 100,
      'start': 1,
      'Cover': 'Big',
      'SearchTarget': 'Book',
      'InputEncoding': 'utf-8',
      'Output': 'js'
    };
    function12();
  }

  var str;
  function12() async {
    var listURI = "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx?";
    var response = await Requests.post(listURI, headers: header, body: data);
    print(response.statusCode);

    setState(() {
      data =
          jsonDecode(response.body.replaceAll(";", "").replaceAll("\\'", ""));
    });
  }

  var barcode, f_page_img;

  AddImg(i) {
    setState(() {
      f_page_img = i;
    });
  }

  AddBarcode(i) {
    setState(() {
      barcode = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('도서 목록'), actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) =>
                        FinalConfirm(barcode: barcode, fImg: f_page_img))),
              );
            },
          )
        ]),
        body: bookTimeline(data: data, AddBarcode: AddBarcode, AddImg: AddImg));
  }
}

class bookTimeline extends StatefulWidget {
  bookTimeline({Key? key, this.data, this.AddBarcode, this.AddImg})
      : super(key: key);
  var data;
  final AddBarcode;
  final AddImg;
  @override
  State<bookTimeline> createState() => _bookTimelineState();
}

class _bookTimelineState extends State<bookTimeline> {
  var scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        print(widget.data.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.data['item'].length,
        controller: scroll,
        itemBuilder: (context, i) {
          return ListTile(
            title: Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Row(
                children: [
                  Image.network(
                    widget.data['item'][i]['cover'],
                    height: 100,
                    width: 100,
                  ),
                  Column(
                    children: [
                      Container(
                        width: 300,
                        child: Text(widget.data['item'][i]['title'].toString()),
                      ),
                      Container(
                          width: 300,
                          child: Text(
                              widget.data['item'][i]['author'].toString())),
                      Container(
                          width: 300,
                          child: Text(
                            widget.data['item'][i]['publisher'].toString(),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            selectedColor: Colors.grey[600],
            onTap: () {
              widget.AddImg(widget.data['item'][i]['cover']);
              widget.AddBarcode(widget.data['item'][i]['isbn13']);
              print(widget.data['item'][i]['isbn13']);
            },
          );
        },
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}

class Store extends ChangeNotifier {
  var applyStatus;

  getData_h(barcode) async {
    Map<String, String> headers = {};
    var URI = 'http://www.kyoboacademy.co.kr/lipss/wishbook/index.laf?';
    var result = await http.post(Uri.parse(URI), body: {"libCd": "00138"});

    if (result.headers['set-cookie'].runtimeType == String) {
      headers['cookie'] = result.headers['set-cookie'].toString();
    }
    print(headers['cookie']);
    var URL = Uri.parse(
        "http://www.kyoboacademy.co.kr/wsclient/requestWishbook.laf?libCd=00138&univCd=11409&ipid=2080617575&patronAid=&wishMemNo=&wishMemId=&wishMemNm=%B9%E9%C7%CF%C1%D8&email=baekhajun%40cbnu.ac.kr&memType=STU&solNm=STU&comment=&barcode=${barcode}&ejkGb=KOR&chkproc=0");
    var result1 = await http.get(URL, headers: headers);
    if (result1.statusCode == 200) {
      print('도서 성공: ${result1.statusCode}');
      applyStatus = result1.statusCode;
    } else {
      throw Exception('도서 실패: ${result1.statusCode}');
    }
    notifyListeners();
  }
}

class FinalConfirm extends StatefulWidget {
  const FinalConfirm({this.fImg, this.barcode}) : super();
  final barcode;
  final fImg;

  @override
  State<FinalConfirm> createState() => _FinalConfirmState();
}

class _FinalConfirmState extends State<FinalConfirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('최종 페이지'),
      ),
      body: Column(
        children: [
          Image.network(widget.fImg),
          TextField(
            decoration: InputDecoration(hintText: '요청 사항'),
          ),
          Text('신청 버튼을 누르면 해당 도서가 희망도서로 신청됩니다.'),
          Text('신청하시겠습니까?'),
          TextButton(
            child: Text('신청'),
            onPressed: () {
              context.read<Store>().getData_h(widget.barcode);
              Navigator.push(
                  context, MaterialPageRoute(builder: ((context) => sucess())));
            },
          ),
        ],
      ),
    );
  }
}

class sucess extends StatelessWidget {
  const sucess() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('신청 성공')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('신청이 완료되었습니다.'),
            TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
// Navigator.push(context, MaterialPageRoute(builder: (context) => NewPage()),);
                },
                child: Text('돌아가기'))
          ],
        ),
      ),
    );
  }
}
