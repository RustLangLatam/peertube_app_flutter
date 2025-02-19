import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

/// Extension for VideoConstantNumberCategory to generate GetAccountVideosCategoryOneOfParameter.
extension VideoConstantNumberCategoryExt on VideoConstantNumberCategory {
  /// Returns GetAccountVideosCategoryOneOfParameter based on the category id.
  ///
  /// This property is used to generate a parameter for fetching account videos
  /// based on a specific category.
  GetAccountVideosCategoryOneOfParameter get oneOfParameter {
    // Create a new GetAccountVideosCategoryOneOfParameter and set its oneOf property
    // to the category id using OneOf.fromValue1.
    return GetAccountVideosCategoryOneOfParameter((p) => p..oneOf = OneOf.fromValue1(value: id!));
  }
}

/// Extension for String to generate GetAccountVideosTagsOneOfParameter.
extension TagStringExt on String {
  /// Returns GetAccountVideosTagsOneOfParameter based on the tag string.
  ///
  /// This property is used to generate a parameter for fetching account videos
  /// based on a specific tag.
  GetAccountVideosTagsOneOfParameter get oneOfParameter {
    // Create a new GetAccountVideosTagsOneOfParameter and set its oneOf property
    // to the tag string using OneOf.fromValue1.
    return GetAccountVideosTagsOneOfParameter((p) => p..oneOf = OneOf.fromValue1(value: this));
  }
}