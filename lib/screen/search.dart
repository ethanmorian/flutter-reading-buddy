import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_reading_buddy/model/Book.dart';
import 'package:flutter_reading_buddy/service/adHelper.dart';
import 'package:flutter_reading_buddy/service/bookApi.dart';
import 'package:flutter_reading_buddy/service/databaseSvc.dart';
import 'package:flutter_reading_buddy/widget/bookCoverBox.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Book> books = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool showLatestBookRecommendation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRewardedAd();
  }

  Future<void> searchBook(String keyword) async {
    setState(() {
      _isLoading = true;
    });

    var searchResult = await BookApi.getBookInformation(keyword);

    setState(() {
      books = searchResult;
      _isLoading = books.isEmpty;
    });
  }

  // TODO: Add _rewardedAd
  RewardedAd? _rewardedAd;

  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    _rewardedAd?.show(
                      onUserEarnedReward: (_, reward) {
                        showLatestBookRecommendation = true;
                      },
                    );
                  },
                  icon: const Icon(Icons.gif_box),
                ),
                if (showLatestBookRecommendation) const Text('최근 뜨는 책! : 호모데우스'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search A Book',
                          hintStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) => searchBook(value),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          books = [];
                        });
                      },
                      icon: const Icon(Icons.clear))
                ],
              ),
            ),
            Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {},
                            child: Container(
                              child: BookCoverBox(
                                name: books[index].name,
                                imgUrl: books[index].imgUrl,
                                bookKey: books[index].bookKey,
                              ),
                            ),
                          );
                        },
                      ))
          ],
        ),
      ),
    );
  }
}
