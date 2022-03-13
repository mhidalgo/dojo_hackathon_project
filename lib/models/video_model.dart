class VideoModel {
  String? videoUrl;
  var uploadedAt;
  String? videoName;
  bool? finishedProcessing;
  String? uploadUrl;
  String? rawVideoPath;
  bool? uploadComplete;

  VideoModel({
    this.videoUrl,
    this.videoName,
    this.uploadedAt,
    this.finishedProcessing,
    this.uploadUrl,
    this.rawVideoPath,
    this.uploadComplete,
  });
}