import 'dart:async';

class CompositeSubscription {
  final List<StreamSubscription> _subscriptions;

  CompositeSubscription(this._subscriptions);

  void cancel() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
