import 'dart:convert';

import 'package:app_gifs/controller/controller.dart';
import 'package:app_gifs/model/gif.dart';
import 'package:app_gifs/view/gif_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Gif> _gifs = [];
  late Future<bool> isLoaded;

  @override
  void initState() {
    super.initState();
    isLoaded = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.black,
          title: GestureDetector(
            onTap: () {
              setState(() {
                _gifs.clear();
                _searchController.text = '';
              });
              isLoaded = _getGifs();
            },
            child: Image.network(
                "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      keyboardType: TextInputType.name,
                      cursorColor: Colors.white,
                      onFieldSubmitted: (value) {
                        search();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search gifs',
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    onPressed: search,
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(60),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: FutureBuilder(
                  future: isLoaded,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Container();
                        } else {
                          return SmartRefresher(
                            onLoading: _onLoading,
                            //onRefresh: _onRefresh,
                            controller: _refreshController,
                            enablePullDown: false,
                            enablePullUp: true,
                            footer: CustomFooter(
                              builder:
                                  (BuildContext context, LoadStatus? mode) {
                                Widget body;
                                if (mode == LoadStatus.idle) {
                                  body = const Text("Pull up load");
                                } else if (mode == LoadStatus.loading) {
                                  body = const CupertinoActivityIndicator();
                                } else if (mode == LoadStatus.failed) {
                                  body =
                                      const Text("Load Failed! Click retry!");
                                } else if (mode == LoadStatus.canLoading) {
                                  body = const Text("Release to load more");
                                } else {
                                  body = const Text("No more Data");
                                }
                                return SizedBox(
                                  height: 55.0,
                                  child: Center(child: body),
                                );
                              },
                            ),
                            child: GridView.builder(
                              itemCount: _gifs.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 10.0),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onLongPress: () {
                                    Share.share(_gifs[index].image);
                                  },
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GifPage(gif: _gifs[index])));
                                  },
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: _gifs[index].image,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _getGifs() async {
    try {
      final response = await Controller.getGifsApi(offset: _gifs.length);
      final responseDecoded = jsonDecode(response.body);
      final List<dynamic> dataGifs = responseDecoded['data'];

      if (response.statusCode == 200) {
        setState(() {
          _gifs += dataGifs
              .map((e) => Gif(
                  image: e['images']['fixed_height']['url'], title: e['title']))
              .toList();
        });
        return true;
      }
      _refreshController.loadFailed();
      return false;
    } catch (e) {
      _refreshController.loadFailed();
      return false;
    }
  }

  Future<bool> _getSearchGifs(String search) async {
    try {
      final response = await Controller.getSearchGifApi(
          search: search, offset: _gifs.length);
      final responseDecoded = jsonDecode(response.body);
      final List<dynamic> dataGifs = responseDecoded['data'];

      if (response.statusCode == 200) {
        setState(() {
          _gifs += dataGifs
              .map((e) => Gif(
                  image: e['images']['fixed_height']['url'], title: e['title']))
              .toList();
        });
        return true;
      }
      _refreshController.loadFailed();
      return false;
    } catch (e) {
      _refreshController.loadFailed();
      return false;
    }
  }

  void _onLoading() async {
    final int length = _gifs.length;
    if (_searchController.text.isEmpty) {
      await _getGifs();
    } else {
      await _getSearchGifs(_searchController.text);
    }
    if (length == _gifs.length) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  void search() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _gifs.clear();
      });
      isLoaded = _getSearchGifs(_searchController.text);
    }
  }
}
