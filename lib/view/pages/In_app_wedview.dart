import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Google_APP extends StatefulWidget {
  const Google_APP({super.key});

  @override
  State<Google_APP> createState() => _Google_APPState();
}

class _Google_APPState extends State<Google_APP> {
  InAppWebViewController? _inAppWebViewController;
  TextEditingController? t = TextEditingController();
  late PullToRefreshController pullToRefreshController;
  List<String> link = [];

  @override
  void initState() {
    // TODO: implement initState
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        await _inAppWebViewController!.reload();
      },
    );
    super.initState();
  }

  double progress = 0;
  String url = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Go Back"),
                onTap: () async {
                  return await _inAppWebViewController!.goBack();
                },
              ),
              PopupMenuItem(
                child: Text("Go forward"),
                onTap: () async {
                  return await _inAppWebViewController!.goForward();
                },
              ),
              PopupMenuItem(
                child: Text("Go resrart"),
                onTap: () async {
                  return await _inAppWebViewController!.reload();
                },
              ),
              PopupMenuItem(
                child: Text("Go Home"),
                onTap: () async {
                  return await _inAppWebViewController!.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse("https://www.google.co.in"),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              Uri? k = await _inAppWebViewController?.getUrl();
              link.add(k.toString());
              print("$k");
            },
            child: Icon(Icons.bookmark_add_outlined),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "History Of Book Mark",
                    style: TextStyle(fontSize: 14),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...link.map(
                          (e) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _inAppWebViewController!.loadUrl(
                                    urlRequest: URLRequest(
                                      url: Uri.parse("$e"),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 50,
                                  width: 150,
                                  child: Expanded(
                                    child: Container(
                                      child: Text(
                                        "$e",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Icon(Icons.bookmark),
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: t,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              var url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("https://www.google.com/search?q=" + value);
              }
              _inAppWebViewController?.loadUrl(
                  urlRequest: URLRequest(url: url));
            },
          ),
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : Container(),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse("https://www.google.co.in"),
              ),
              onWebViewCreated: (controller) {
                _inAppWebViewController = controller;
              },
              // initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onLoadStop: (controller, url) async {
                await pullToRefreshController.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                  t?.text = this.url;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
