import 'package:webrtc/MediaStreamTrack.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MediaStream {
  MethodChannel _channel = WebRTC.methodChannel();
  String _streamId;
  List<MediaStreamTrack> _audioTracks = new List<MediaStreamTrack>();
  List<MediaStreamTrack> _videoTracks = new List<MediaStreamTrack>();
  MediaStream(this._streamId) {
    initialize();
  }

  void initialize() async {
    _channel = WebRTC.methodChannel();
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'mediaStreamGetTracks',
      <String, dynamic>{'streamId': _streamId},
    );

    List<dynamic> audioTracks = response['audioTracks'];
    audioTracks.forEach((track){ 
      _audioTracks.add(new MediaStreamTrack(track["id"], track["label"], track["kind"], track["enabled"]));
    });

    List<dynamic> videoTracks = response['videoTracks'];
    videoTracks.forEach((track){
        _videoTracks.add(new MediaStreamTrack(track["id"], track["label"], track["kind"], track["enabled"]));
    });
  }

  String get id => _streamId;
  addTrack(MediaStreamTrack track) {
    if (track.kind == 'audio')
      _audioTracks.add(track);
    else
      _videoTracks.add(track);

    _channel.invokeMethod('mediaStreamAddTrack',
        <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
  }

  removeTrack(MediaStreamTrack track) {
    if (track.kind == 'audio')
      _audioTracks.remove(track);
    else
      _videoTracks.remove(track);

    _channel.invokeMethod('mediaStreamRemoveTrack',
        <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
  }

  List<MediaStreamTrack> getAudioTracks() {
    return _audioTracks;
  }

  List<MediaStreamTrack> getVideoTracks() {
    return _videoTracks;
  }

  @override
  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'streamDispose',
      <String, dynamic>{'streamId': _streamId},
    );
  }
}
