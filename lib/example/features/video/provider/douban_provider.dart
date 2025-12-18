import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';

class DoubanProvider extends ChangeNotifier {
  final DioClient dioClient;
  
  List<VideoModel> hotVideos = [];
  bool isLoading = false;
  String? errorMessage;

  DoubanProvider({required this.dioClient});

  /// 获取豆瓣热门视频
  Future<void> fetchHotVideos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 豆瓣 API 端点 - 获取热映电影
      const String url = 'https://movie.douban.com/j/search_subjects';
      
      // 需要添加正确的请求头来避免 400 错误
      final response = await dioClient.dio.get(
        url,
        queryParameters: {
          'type': 'movie',
          'tag': '热映',
          'page_limit': '20',
          'page_start': '0',
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://movie.douban.com/explore',
          },
          validateStatus: (status) {
            // 接受所有状态码，手动处理
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data != null && data is Map && data['subjects'] is List) {
          final subjects = (data['subjects'] as List).cast<Map<String, dynamic>>();
          
          hotVideos = subjects.map((subject) {
            return VideoModel(
              id: subject['id']?.toString() ?? '',
              title: subject['title']?.toString() ?? '未知标题',
              thumbnail: subject['cover']?.toString() ?? '',
              duration: '${subject['duration'] ?? '未知'}分钟',
              pic: subject['cover']?.toString() ?? '',
              detail: subject['description']?.toString() ?? subject['title']?.toString() ?? '暂无简介',
              from: 'douban',
            );
          }).toList();

          print('✅ 成功获取 ${hotVideos.length} 部热门视频');
        } else {
          errorMessage = '数据格式错误';
          print('❌ 数据格式错误: $data');
        }
      } else {
        errorMessage = '获取数据失败 (${response.statusCode}): ${response.statusMessage}';
        print('❌ 获取数据失败: ${response.statusCode} ${response.statusMessage}');
        print('❌ 响应体: ${response.data}');
        
        // 失败时使用本地模拟数据
        print('⚠️ 使用本地示例数据替代');
        hotVideos = _getMockVideos();
        errorMessage = null; // 清除错误信息，正常显示
      }
    } on DioException catch (e) {
      errorMessage = '网络错误: ${e.message}';
      print('❌ 网络错误: ${e.message}');
      print('❌ 详情: ${e.error}');
      
      // 网络错误时使用本地模拟数据
      print('⚠️ 使用本地示例数据替代');
      hotVideos = _getMockVideos();
      errorMessage = null; // 清除错误信息，正常显示
    } catch (e) {
      errorMessage = '未知错误: $e';
      print('❌ 未知错误: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 初始化时获取热门视频
  void initialize() {
    if (hotVideos.isEmpty) {
      fetchHotVideos();
    }
  }

  /// 获取本地模拟视频数据（API 失败时的备用方案）
  List<VideoModel> _getMockVideos() {
    return [
      VideoModel(
        id: '1',
        title: '肖申克救赎',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716440.webp',
        duration: '142分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716440.webp',
        detail: '一段被演绎成生命本身的友谊，一部被誉为电影史诗的杰作。',
        from: 'douban',
      ),
      VideoModel(
        id: '2',
        title: '霸王别姬',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716404.webp',
        duration: '171分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716404.webp',
        detail: '一出跨越半个世纪的京剧悲歌，一段深入骨髓的绝世情缘。',
        from: 'douban',
      ),
      VideoModel(
        id: '3',
        title: '这个杀手不太冷',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716430.webp',
        duration: '110分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716430.webp',
        detail: '一个职业杀手与一个小女孩的意外相遇，演绎出一段温情的故事。',
        from: 'douban',
      ),
      VideoModel(
        id: '4',
        title: '泰坦尼克号',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716455.webp',
        duration: '194分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716455.webp',
        detail: '一个关于爱、阶级和命运的史诗级爱情故事，全球票房冠军。',
        from: 'douban',
      ),
      VideoModel(
        id: '5',
        title: '阿甘正传',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716420.webp',
        duration: '142分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716420.webp',
        detail: '一个低能儿却用实际行动诠释了什么叫坚持和执着。',
        from: 'douban',
      ),
      VideoModel(
        id: '6',
        title: '美丽人生',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716410.webp',
        duration: '116分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716410.webp',
        detail: '在人类最黑暗的时刻，爱与幽默照亮了前路。',
        from: 'douban',
      ),
      VideoModel(
        id: '7',
        title: '活着',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716425.webp',
        duration: '125分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716425.webp',
        detail: '一部关于生命意义的深刻思考，余华的经典改编。',
        from: 'douban',
      ),
      VideoModel(
        id: '8',
        title: '搏击俱乐部',
        thumbnail: 'https://img3.doubanio.com/view/photo/s/public/p2561716435.webp',
        duration: '139分钟',
        pic: 'https://img3.doubanio.com/view/photo/s/public/p2561716435.webp',
        detail: '一部充满哲学思想的黑色幽默电影，结局令人震撼。',
        from: 'douban',
      ),
    ];
  }
}
