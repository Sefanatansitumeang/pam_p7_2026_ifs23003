class RouteConstants {
  RouteConstants._();

  static const String home    = '/';
  static const String plants  = '/plants';
  static const String plantsAdd = '/plants/add';
  static String plantsDetail(String id) => '/plants/$id';
  static String plantsEdit(String id)   => '/plants/$id/edit';

  static const String space      = '/space';
  static const String spaceAdd   = '/space/add';
  static String spaceDetail(String id) => '/space/$id';
  static String spaceEdit(String id)   => '/space/$id/edit';

  static const String profile = '/profile';
}