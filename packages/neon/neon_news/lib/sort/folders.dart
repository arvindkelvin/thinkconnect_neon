part of '../neon_news.dart';

final foldersSortBox = SortBox<FoldersSortProperty, FolderFeedsWrapper>(
  {
    FoldersSortProperty.alphabetical: (final folderFeedsWrapper) => folderFeedsWrapper.folder.name.toLowerCase(),
    FoldersSortProperty.unreadCount: (final folderFeedsWrapper) => feedsUnreadCountSum(folderFeedsWrapper.feeds),
  },
  {
    FoldersSortProperty.alphabetical: Box(FoldersSortProperty.unreadCount, SortBoxOrder.descending),
    FoldersSortProperty.unreadCount: Box(FoldersSortProperty.alphabetical, SortBoxOrder.ascending),
  },
);

class FolderFeedsWrapper {
  FolderFeedsWrapper(
    this.folder,
    this.feeds,
  );

  final NextcloudNewsFolder folder;
  final List<NextcloudNewsFeed> feeds;
}

int feedsUnreadCountSum(final List<NextcloudNewsFeed> feeds) => feeds.fold(0, (final a, final b) => a + b.unreadCount!);
