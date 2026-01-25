class Detail {
  String? summarizedDescription;
  String? summarizedDescription_am;
  String? summarizedDescription_or;
  String? summarizedDescription_tr;
  String? summarizedDescription_so;

  String? figCaption;
  String? figCaption_or;
  String? figCaption_am;
  String? figCaption_tr;
  String? figCaption_so;

  String? summarized;
  String? summarized_or;
  String? summarized_am;
  String? summarized_tr;
  String? summarized_so;

  String? summarizedTitle;
  String? summarizedTitle_or;
  String? summarizedTitle_am;
  String? summarizedTitle_tr;
  String? summarizedTitle_so;

  String? author;
  String? author_or;
  String? author_am;
  String? author_tr;
  String? author_so;

  String? source;
  String? sourceimage;
  String? sourcename;

  bool? is_processed;

  String? transcriptions_am;
  String? transcriptions_or;
  String? transcriptions_tr;
  String? transcriptions_so;

  String? title;

  Detail({
    this.title,
    this.description,
    this.mainImage,
    this.publishedDate,
    this.id,
    this.language,
    this.commonId,
    this.newsLink,
    this.summarizedDescription,
    this.summarizedDescription_am,
    this.summarizedDescription_or,
    this.summarizedDescription_tr,
    this.summarizedDescription_so,
    this.figCaption,
    this.figCaption_or,
    this.figCaption_am,
    this.figCaption_tr,
    this.figCaption_so,
    this.summarized,
    this.summarized_or,
    this.summarized_am,
    this.summarized_tr,
    this.summarized_so,
    this.summarizedTitle,
    this.summarizedTitle_or,
    this.summarizedTitle_am,
    this.summarizedTitle_tr,
    this.summarizedTitle_so,
    this.author,
    this.author_or,
    this.author_am,
    this.author_tr,
    this.author_so,
    this.data,
    this.is_processed,
    this.transcriptions_am,
    this.transcriptions_or,
    this.transcriptions_tr,
    this.transcriptions_so,
    this.source,
    this.sourceimage,
    this.sourcename,
    required this.time,
  });

  String? description;
  String? mainImage;

  String? publishedDate;
  String? id;
  String? language;
  String? commonId;
  String? newsLink;
  String time;

  dynamic data;

  factory Detail.fromJson(json) => Detail(
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mainImage: json['mainImage'] ?? '',
      figCaption: json['figCaption'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      id: json['id'] ?? '',
      language: json['language'] ?? '',
      commonId: json['commonId'] ?? '',
      newsLink: json['newsLink'] ?? '',
      time: json['publishedDate'] ?? '',
      summarizedDescription: json['summarizedDescription'] ?? '',
      summarizedDescription_am: json['summarizedDescription_am'] ?? '',
      summarizedDescription_or: json['summarizedDescription_or'] ?? '',
      summarizedDescription_tr: json['summarizedDescription_tr'] ?? '',
      summarizedDescription_so: json['summarizedDescription_so'] ?? '',
      figCaption_or: json['figCaption_or'] ?? '',
      figCaption_am: json['figCaption_am'] ?? '',
      figCaption_tr: json['figCaption_tr'] ?? '',
      figCaption_so: json['figCaption_so'] ?? '',
      summarized: json['summarized'] ?? '',
      summarized_or: json['summarized_or'] ?? '',
      summarized_am: json['summarized_am'] ?? '',
      summarized_tr: json['summarized_tr'] ?? '',
      summarized_so: json['summarized_so'] ?? '',
      summarizedTitle: json['summarizedTitle'] ?? '',
      summarizedTitle_or: json['summarizedTitle_or'] ?? '',
      summarizedTitle_am: json['summarizedTitle_am'] ?? '',
      summarizedTitle_tr: json['summarizedTitle_tr'] ?? '',
      summarizedTitle_so: json['summarizedTitle_so'] ?? '',
      author_or: json['author_or'] ?? '',
      author_am: json['author_am'] ?? '',
      author_tr: json['author_tr'] ?? '',
      author_so: json['author_so'] ?? '',
      transcriptions_am: json['transcriptions_am'],
      transcriptions_or: json['transcriptions_or'],
      transcriptions_so: json['transcriptions_so'],
      transcriptions_tr: json['transcriptions_tr'],
      source: json['source'],
      sourcename: json['sourcename'],
      sourceimage: json['sourceimage'],
      is_processed: json['is_processed'],
      data: json);
}

class sas_toke {
  String sas_token;
  sas_toke({required this.sas_token});

  factory sas_toke.fromJson(json) => sas_toke(sas_token: json['token']);
}
