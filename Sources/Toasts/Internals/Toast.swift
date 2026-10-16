import Foundation

@MainActor
@dynamicMemberLookup
internal final class ToastModel: ObservableObject, Identifiable {
  @Published internal var value: ToastValue
  /// Bumped to restart the dismiss timer, which the view observes.
  @Published internal var restartCount = 0
  internal init(value: ToastValue) {
    self.value = value
  }

  internal subscript<V>(dynamicMember keyPath: WritableKeyPath<ToastValue, V>) -> V {
    get { value[keyPath: keyPath] }
    set { value[keyPath: keyPath] = newValue }
  }
}
