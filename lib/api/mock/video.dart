import 'package:utopia_front/api/model/video.dart';

import '../abstract/video.dart';

class VideoApiMock extends VideoApi {
  @override
  Future<VideoResponse> getVideoList(VideoRequest request) {
    return Future.delayed(const Duration(seconds: 1), () {
      VideoResponse videoResponse = VideoResponse(
          code: 2000,
          msg: 'ok',
          data: VideoData(
            videoInfo: [
              VideoInfo(
                id: 3,
                createdAt: "2023-10-28T13:23:24.033+08:00",
                playUrl:
                    'https://prod-streaming-video-msn-com.akamaized.net/b7014b7e-b38f-4a64-bd95-4a28a8ef6dee/113a2bf3-3a5f-45d4-8b6f-e40ce8559da3.mp4',
                coverUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AAOEhRG.img',
                videoTypeId: 1,
                title: '这是我的第一个视频',
                describe: '你好',
                author: Author(
                  id: 7,
                  nickname: 'sgsgds',
                  avatar: 'http://s30hxzidb.bkt.clouddn.com/edd9ff2f.png',
                  username: '车嘉宁',
                  fansCount: 1,
                  followCount: 2,
                  videoCount: 1,
                ),
                isFollow: false,
                isLike: false,
                isFavorite: false,
                likeCount: 120,
                favoriteCount: 0,
                commentCount: 120,
              ),
              VideoInfo(
                id: 7,
                createdAt: "2023-10-27T22:16:25.352+08:00",
                playUrl:
                    'https://prod-streaming-video-msn-com.akamaized.net/178161a4-26a5-4f84-96d3-6acea1909a06/2213bcd0-7d15-4da0-a619-e32d522572c0.mp4',
                coverUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AAOEa6N.img',
                videoTypeId: 1,
                describe: '这是我的一个视频描述',
                author: Author(
                  id: 9,
                  nickname: 'fsd啊',
                  avatar: 'http://s3dh6uw2g.bkt.clouddn.com/tesljas35.png',
                  username: '冰航',
                  fansCount: 2,
                  followCount: 3,
                  videoCount: 7,
                ),
                title: '这是我的一个视频标题',
                isFollow: false,
                isLike: false,
                isFavorite: false,
                likeCount: 120,
                favoriteCount: 230,
                commentCount: 10,
              ),
              VideoInfo(
                id: 10,
                createdAt: "2023-10-28T13:23:24.033+08:00",
                playUrl:
                    'https://prod-streaming-video-msn-com.akamaized.net/fe13f13c-c2cc-4998-b525-038b23bfa9b5/1a9d30ca-54be-411e-8b09-d72ef4488e05.mp4',
                coverUrl: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AAOEcge.img',
                videoTypeId: 1,
                title: '标题',
                describe: '描述',
                author: Author(
                  id: 11,
                  nickname: 'd56e2a96',
                  avatar: 'http://s351j97d8.hd-bkt.clouddn.com/d56e2a96.png',
                  username: 'admin',
                  fansCount: 0,
                  followCount: 0,
                  videoCount: 8,
                ),
                isFollow: false,
                isLike: false,
                isFavorite: false,
                likeCount: 2,
                favoriteCount: 1,
                commentCount: 0,
              ),
            ],
            nextTime: 1698470604033,
          ));
      return videoResponse;
    });
  }

  @override
  Future<VideoResponseNoNextTime> searchVideoList(SearchVideoRequest request) {
    // TODO: implement searchVideoList
    throw UnimplementedError();
  }

  @override
  Future<VideoResponse> getVideoListByUserId(SomeoneVideoRequest request) {
    // TODO: implement getVideoListByUserId
    throw UnimplementedError();
  }

  @override
  Future<SingleVideoResponse> getVideoByVideoId(VideoByVideoIdRequest request) {
    // TODO: implement getVideoByVideoId
    throw UnimplementedError();
  }

  @override
  Future<HotVideoResponse> getHotVideoList(HotVideoRequest request) {
    // TODO: implement getHotVideoList
    throw UnimplementedError();
  }
}
