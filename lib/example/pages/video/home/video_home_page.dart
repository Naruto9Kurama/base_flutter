import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:base_flutter/example/pages/video/search/video_search.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:async';

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({Key? key}) : super(key: key);

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildTabs(),
          // 使用 TabBarView 实现局部刷新
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _MovieTabContent(category: '热门', tabName: '为你推荐'),
                _MovieTabContent(category: '经典', tabName: '电影'),
                _MovieTabContent(category: '剧集', tabName: '电视剧'),
                _MovieTabContent(category: '动画', tabName: '动漫'),
                _MovieTabContent(category: '纪录片', tabName: '纪录片'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFFB20710)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '影视',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VideoSearchPage(),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE50914),
            child: const Icon(Icons.person, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFE50914),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs: const [
            Tab(text: '为你推荐'),
            Tab(text: '电影'),
            Tab(text: '电视剧'),
            Tab(text: '动漫'),
            Tab(text: '纪录片'),
          ],
        ),
      ),
    );
  }
}

// 每个 Tab 的内容组件
class _MovieTabContent extends StatefulWidget {
  final String category;
  final String tabName;

  const _MovieTabContent({
    required this.category,
    required this.tabName,
  });

  @override
  State<_MovieTabContent> createState() => _MovieTabContentState();
}

class _MovieTabContentState extends State<_MovieTabContent>
    with AutomaticKeepAliveClientMixin {
  List<Movie> _topMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _actionMovies = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // 保持状态，避免重复加载

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://movie.douban.com/j/search_subjects?type=movie&tag=${widget.category}&page_limit=30&page_start=0',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final subjects = data['subjects'] as List;
        final movies = subjects.map((item) => Movie.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            if (movies.length >= 30) {
              _topMovies = movies.sublist(0, 10);
              _trendingMovies = movies.sublist(10, 20);
              _actionMovies = movies.sublist(20, 30);
            } else if (movies.length >= 20) {
              _topMovies = movies.sublist(0, 10);
              _trendingMovies = movies.sublist(10, 20);
              _actionMovies = movies.sublist(10, 20);
            } else if (movies.length >= 10) {
              _topMovies = movies.sublist(0, 10);
              _trendingMovies = movies;
              _actionMovies = movies;
            } else {
              _topMovies = movies;
              _trendingMovies = movies;
              _actionMovies = movies;
            }
            _isLoading = false;
          });
        }
      } else {
        _loadMockData();
      }
    } catch (e) {
      _loadMockData();
    }
  }

  void _loadMockData() {
    if (mounted) {
      setState(() {
        _topMovies = List.generate(
          10,
          (i) => Movie(
            id: 'top_$i',
            title: '${widget.tabName}热门 ${i + 1}',
            cover: '',
            rate: (8.5 - i * 0.2).toStringAsFixed(1),
            year: '2024',
            genres: ['动作', '冒险'],
          ),
        );

        _trendingMovies = List.generate(
          10,
          (i) => Movie(
            id: 'trend_$i',
            title: '${widget.tabName}趋势 ${i + 1}',
            cover: '',
            rate: (8.0 - i * 0.2).toStringAsFixed(1),
            year: '2024',
            genres: ['剧情', '爱情'],
          ),
        );

        _actionMovies = List.generate(
          10,
          (i) => Movie(
            id: 'action_$i',
            title: '${widget.tabName}精选 ${i + 1}',
            cover: '',
            rate: (7.5 - i * 0.2).toStringAsFixed(1),
            year: '2023',
            genres: ['动作', '科幻'],
          ),
        );

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于 AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE50914)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMovies,
      color: const Color(0xFFE50914),
      child: CustomScrollView(
        slivers: [
          _buildSectionTitle(_getSectionTitle(0), _topMovies, '高分推荐'),
          _buildHorizontalMovieList(_topMovies),
          _buildSectionTitle(_getSectionTitle(1), _trendingMovies, '热门趋势'),
          _buildHorizontalMovieList(_trendingMovies),
          _buildSectionTitle(_getSectionTitle(2), _actionMovies, '精选推荐'),
          _buildMovieGrid(_actionMovies),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  String _getSectionTitle(int section) {
    final titles = {
      '热门': ['高分推荐', '热门趋势', '动作冒险'],
      '经典': ['经典电影', '热门上映', '高分佳作'],
      '剧集': ['热播剧集', '经典剧集', '精选推荐'],
      '动画': ['热门动漫', '经典动画', '新番推荐'],
      '纪录片': ['精选纪录片', '热门纪录片', '历史人文'],
    };

    return titles[widget.category]?[section] ?? '推荐内容';
  }

  Widget _buildSectionTitle(String title, List<Movie> movies, String sectionType) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _showAllMovies(title, movies, sectionType);
              },
              child: const Text(
                '查看全部',
                style: TextStyle(color: Color(0xFFE50914)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllMovies(String title, List<Movie> movies, String sectionType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AllMoviesPage(
          title: title,
          movies: movies,
          category: widget.category,
          sectionType: sectionType,
        ),
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<Movie> movies) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return _buildMovieCard(movies[index], width: 140);
          },
        ),
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMovieCard(movies[index]),
          childCount: movies.length,
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, {double? width}) {
    return GestureDetector(
      onTap: () async {
        final onValue = await GetIt.instance
            .get<BaseVodRespository>()
            .searchVideo("jy", movie.title, 1, 1);
        if (context.mounted) {
          context.push('/video-player', extra: onValue.first);
        }
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie.cover.isNotEmpty
                          ? DoubanImage(imageUrl: movie.cover)
                          : const Center(child: Icon(Icons.movie, size: 40)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            movie.rate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              movie.year,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

// 查看全部页面
class _AllMoviesPage extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final String category;
  final String sectionType;

  const _AllMoviesPage({
    required this.title,
    required this.movies,
    required this.category,
    required this.sectionType,
  });

  @override
  State<_AllMoviesPage> createState() => _AllMoviesPageState();
}

class _AllMoviesPageState extends State<_AllMoviesPage> {
  List<Movie> _allMovies = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _allMovies = List.from(widget.movies);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMovies();
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final response = await http.get(
        Uri.parse(
          'https://movie.douban.com/j/search_subjects?type=movie&tag=${widget.category}&page_limit=20&page_start=${_currentPage * 20}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final subjects = data['subjects'] as List;
        final newMovies = subjects.map((item) => Movie.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            _allMovies.addAll(newMovies);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text(widget.title),
        elevation: 0,
      ),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _allMovies.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allMovies.length) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          final movie = _allMovies[index];
          return GestureDetector(
            onTap: () async {
              final onValue = await GetIt.instance
                  .get<BaseVodRespository>()
                  .searchVideo("jy", movie.title, 1, 1);
              if (context.mounted) {
                context.push('/video-player', extra: onValue.first);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[800],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: movie.cover.isNotEmpty
                              ? DoubanImage(imageUrl: movie.cover)
                              : const Center(
                                  child: Icon(Icons.movie, size: 40)),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                movie.rate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  movie.year,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF0D0D0D), child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

class Movie {
  final String id;
  final String title;
  final String cover;
  final String rate;
  final String year;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.cover,
    required this.rate,
    required this.year,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      rate: json['rate']?.toString() ?? '0.0',
      year: '2024',
      genres: ['电影', '热门'],
    );
  }

  factory Movie.fromSearchJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['sub_title'] ?? '',
      cover: json['img'] ?? '',
      rate: json['rate']?.toString() ?? '0.0',
      year: json['year']?.toString() ?? '2024',
      genres: ['电影'],
    );
  }
}

class DoubanImage extends StatefulWidget {
  final String imageUrl;

  const DoubanImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<DoubanImage> createState() => _DoubanImageState();
}

class _DoubanImageState extends State<DoubanImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: {
          'Referer': 'https://movie.douban.com/',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _imageData = response.bodyBytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
          ),
        ),
      );
    }

    if (_hasError || _imageData == null) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.movie, size: 40, color: Colors.white38),
        ),
      );
    }

    return Image.memory(
      _imageData!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
