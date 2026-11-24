import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

/// List body for data loaded from the API: loading spinner, error with a
/// Retry button, empty message, and pull-to-refresh on both the list and the
/// empty state.
///
/// The [future] is owned by the screen's `State` (created in `initState`), so
/// rebuilding this widget never sends the request again.
class ApiListView<T> extends StatelessWidget {
  const ApiListView({
    required this.future,
    required this.onRefresh,
    required this.itemBuilder,
    required this.itemName,
    super.key,
  });

  final Future<List<T>> future;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Plural noun used in messages, e.g. `'projects'`.
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final reason = error is ApiException
              ? error.readableMessage
              : '$error';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load $itemName: $reason',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final items = snapshot.data ?? <T>[];
        if (items.isEmpty) {
          // Still pullable so the user can refresh an empty list.
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(child: Text('No $itemName found.')),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(context, items[index]),
          ),
        );
      },
    );
  }
}
