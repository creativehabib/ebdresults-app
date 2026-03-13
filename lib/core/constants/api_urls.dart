class ApiUrls {
  static const token =
      "SDafHV5s5Jiv0V7iMV2eGphWOeXDZ8iFJUhgmrY3BK787qMS0h0xKtJOsBHPa6KR";

  static const base = 'https://ebdresults.com/api/v1';
  static const legacyBase = 'https://ebdresults.com/api';

  static const posts = '$base/posts';
  static const categories = '$base/categories';
  static const tags = '$base/tags';
  static const pages = '$base/pages';
  static const comments = '$base/comments';

  static const legacyJobs = '$legacyBase/jobs';
  static const legacyNews = '$legacyBase/news';

  static String popularPosts({int perPage = 10}) =>
      '$posts?per_page=$perPage&orderby=meta_value_num&meta_key=post_views_count&order=desc';

  static String postsByCategory(int categoryId, {int perPage = 10}) =>
      '$posts?categories=$categoryId&per_page=$perPage&order=desc';

  static String lastModifiedPosts({int perPage = 10}) =>
      '$posts?per_page=$perPage&orderby=modified&order=desc';
}
