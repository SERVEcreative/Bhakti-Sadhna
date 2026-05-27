import 'dart:convert';

import 'package:bhakti_sadhana/config/live_darshan_config.dart';
import 'package:bhakti_sadhana/data/models/live_stream_status.dart';
import 'package:bhakti_sadhana/data/models/live_temple.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// YouTube Data API — channel की **वास्तविक** live playlist से video ID।
class YoutubeLiveStatusService {
  YoutubeLiveStatusService._();
  static final YoutubeLiveStatusService instance = YoutubeLiveStatusService._();

  final _channelIdCache = <String, String>{};
  final _liveStatusCache = <String, _CachedLive>{};

  Future<LiveStreamStatus> resolveForTemple(LiveTemple temple) async {
    if (!LiveDarshanConfig.hasYoutubeApiKey) {
      return const LiveStreamError('api_key_missing');
    }

    try {
      final channelId = await _resolveChannelId(temple);
      if (channelId == null || channelId.isEmpty) {
        return const LiveStreamError('channel_unresolved');
      }
      return _fetchActiveLive(channelId);
    } catch (e, st) {
      debugPrint('YoutubeLiveStatusService: $e\n$st');
      return LiveStreamError(e.toString());
    }
  }

  void clearCacheForTemple(LiveTemple temple) {
    final key = temple.cacheKey;
    final channelId = _channelIdCache[key];
    _channelIdCache.remove(key);
    if (channelId != null) {
      _liveStatusCache.remove(channelId);
    } else {
      _liveStatusCache.clear();
    }
  }

  Future<String?> _resolveChannelId(LiveTemple temple) async {
    final key = temple.cacheKey;
    final cached = _channelIdCache[key];
    if (cached != null) return cached;

    final direct = temple.youtubeChannelId?.trim();
    if (direct != null && direct.isNotEmpty) {
      _channelIdCache[key] = direct;
      return direct;
    }

    final handle = temple.youtubeHandle?.trim();
    if (handle == null || handle.isEmpty) return null;

    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/channels',
      {
        'part': 'id',
        'forHandle': handle.replaceFirst(RegExp(r'^@'), ''),
        'key': LiveDarshanConfig.youtubeApiKey,
      },
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      debugPrint('channels.list ${res.statusCode}: ${res.body}');
      return null;
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;
    final id = (items.first as Map<String, dynamic>)['id'] as String?;
    if (id == null) return null;
    _channelIdCache[key] = id;
    return id;
  }

  Future<LiveStreamStatus> _fetchActiveLive(String channelId) async {
    final cached = _liveStatusCache[channelId];
    if (cached != null && !cached.isExpired) {
      return cached.status;
    }

    var status = await _fetchViaLivePlaylist(channelId);
    if (status is LiveStreamOffline) {
      status = await _fetchViaSearch(channelId);
    }

    status = _attachChannelId(status, channelId);

    _liveStatusCache[channelId] = _CachedLive(
      status,
      DateTime.now().add(LiveDarshanConfig.statusCacheTtl),
    );
    return status;
  }

  LiveStreamStatus _attachChannelId(LiveStreamStatus status, String channelId) {
    return switch (status) {
      LiveStreamLive(:final videoId) =>
        LiveStreamLive(videoId, channelId: channelId),
      LiveStreamEmbedBlocked(:final videoId) =>
        LiveStreamEmbedBlocked(videoId, channelId: channelId),
      _ => status,
    };
  }

  /// Channel की official **live** playlist — सबसे सटीक।
  Future<LiveStreamStatus> _fetchViaLivePlaylist(String channelId) async {
    final chUri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/channels',
      {
        'part': 'contentDetails',
        'id': channelId,
        'key': LiveDarshanConfig.youtubeApiKey,
      },
    );
    final chRes = await http.get(chUri);
    if (chRes.statusCode != 200) {
      debugPrint('channels contentDetails ${chRes.statusCode}');
      return const LiveStreamOffline();
    }

    final chBody = jsonDecode(chRes.body) as Map<String, dynamic>;
    final items = chBody['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return const LiveStreamOffline();

    final content = (items.first as Map<String, dynamic>)['contentDetails']
        as Map<String, dynamic>?;
    final playlists = content?['relatedPlaylists'] as Map<String, dynamic>?;
    final livePlaylistId = playlists?['live'] as String?;
    if (livePlaylistId == null || livePlaylistId.isEmpty) {
      return const LiveStreamOffline();
    }

    final plUri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/playlistItems',
      {
        'part': 'snippet,contentDetails',
        'playlistId': livePlaylistId,
        'maxResults': '1',
        'key': LiveDarshanConfig.youtubeApiKey,
      },
    );
    final plRes = await http.get(plUri);
    if (plRes.statusCode != 200) {
      debugPrint('playlistItems ${plRes.statusCode}');
      return const LiveStreamOffline();
    }

    final plBody = jsonDecode(plRes.body) as Map<String, dynamic>;
    final plItems = plBody['items'] as List<dynamic>?;
    if (plItems == null || plItems.isEmpty) {
      return const LiveStreamOffline();
    }

    final snippet =
        (plItems.first as Map<String, dynamic>)['snippet'] as Map<String, dynamic>?;
    final resourceId = snippet?['resourceId'] as Map<String, dynamic>?;
    final videoId = resourceId?['videoId'] as String?;
    if (videoId == null || videoId.isEmpty) {
      return const LiveStreamOffline();
    }

    return _verifyLiveVideo(videoId);
  }

  Future<LiveStreamStatus> _fetchViaSearch(String channelId) async {
    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'id,snippet',
        'channelId': channelId,
        'type': 'video',
        'eventType': 'live',
        'maxResults': '1',
        'order': 'date',
        'key': LiveDarshanConfig.youtubeApiKey,
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      debugPrint('search.list live ${res.statusCode}: ${res.body}');
      return LiveStreamError('http_${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>?;

    if (items == null || items.isEmpty) {
      return const LiveStreamOffline();
    }

    final first = items.first as Map<String, dynamic>;
    final idMap = first['id'] as Map<String, dynamic>?;
    final videoId = idMap?['videoId'] as String?;
    if (videoId == null || videoId.isEmpty) {
      return const LiveStreamOffline();
    }

    final snippet = first['snippet'] as Map<String, dynamic>?;
    final broadcast = snippet?['liveBroadcastContent'] as String?;
    if (broadcast != null && broadcast != 'live') {
      return const LiveStreamOffline();
    }

    return _verifyLiveVideo(videoId);
  }

  Future<LiveStreamStatus> _verifyLiveVideo(String videoId) async {
    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/videos',
      {
        'part': 'status,liveStreamingDetails,snippet',
        'id': videoId,
        'key': LiveDarshanConfig.youtubeApiKey,
      },
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      debugPrint('videos.list ${res.statusCode}: ${res.body}');
      return LiveStreamLive(videoId);
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) {
      return const LiveStreamOffline();
    }

    final item = items.first as Map<String, dynamic>;
    final statusMap = item['status'] as Map<String, dynamic>?;
    final live = item['liveStreamingDetails'] as Map<String, dynamic>?;
    final snippet = item['snippet'] as Map<String, dynamic>?;

    // लाइव playlist से आया ID — कभी-कभी API में liveStreamingDetails देर से आता है।
    if (live == null) {
      return LiveStreamLive(videoId);
    }
    if (live['actualEndTime'] != null) {
      return const LiveStreamOffline();
    }

    final broadcast = snippet?['liveBroadcastContent'] as String?;
    if (broadcast != null && broadcast != 'live') {
      return const LiveStreamOffline();
    }

    final privacy = statusMap?['privacyStatus'] as String?;
    if (privacy != null && privacy != 'public') {
      return LiveStreamEmbedBlocked(videoId);
    }

    final embeddable = statusMap?['embeddable'] as bool? ?? true;
    if (!embeddable) {
      return LiveStreamEmbedBlocked(videoId);
    }

    return LiveStreamLive(videoId);
  }
}

class _CachedLive {
  _CachedLive(this.status, this.expiresAt);

  final LiveStreamStatus status;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
