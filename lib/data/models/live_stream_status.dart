/// चैनल की वर्तमान लाइव स्थिति।
sealed class LiveStreamStatus {
  const LiveStreamStatus();
}

class LiveStreamLoading extends LiveStreamStatus {
  const LiveStreamLoading();
}

class LiveStreamLive extends LiveStreamStatus {
  const LiveStreamLive(this.videoId, {this.channelId});

  final String videoId;
  final String? channelId;
}

class LiveStreamOffline extends LiveStreamStatus {
  const LiveStreamOffline();
}

/// लाइव है पर ऐप में embed नहीं — YouTube ऐप में खोलें।
class LiveStreamEmbedBlocked extends LiveStreamStatus {
  const LiveStreamEmbedBlocked(this.videoId, {this.channelId});

  final String videoId;
  final String? channelId;
}

class LiveStreamError extends LiveStreamStatus {
  const LiveStreamError(this.message);

  final String message;
}
