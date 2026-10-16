import SwiftUI

@MainActor
internal final class ToastManager: ObservableObject {

  @Published internal var position: ToastPosition = .top
  @Published internal private(set) var models: [ToastModel] = []
  @Published internal private(set) var isAppeared = false
  @Published internal var safeAreaInsets: EdgeInsets = .init()
  @Published internal var style = ToastStyle()
  private var dismissOverlayTask: Task<Void, any Error>?

  internal var isPresented: Bool {
    !models.isEmpty || isAppeared
  }

  nonisolated init() {}

  internal func onAppear() {
    isAppeared = true
  }

  @discardableResult
  internal func append(_ toast: ToastValue) -> ToastModel {
    dismissOverlayTask?.cancel()
    dismissOverlayTask = nil
    if let key = toast.key, let model = models.first(where: { $0.key == key }) {
      var replacement = toast
      replacement.onDismiss = toast.onDismiss ?? model.value.onDismiss
      update(model, to: replacement)
      model.restartCount += 1
      return model
    }
    let model = ToastModel(value: toast)
    models.append(model)
    announceToAccessibility(accessibilityText(for: toast))
    return model
  }

  internal func remove(_ model: ToastModel) {
    if let index = self.models.firstIndex(where: { $0 === model }) {
      self.models.remove(at: index)
      model.value.onDismiss?()
    }
    if models.isEmpty {
      dismissOverlayTask = Task {
        try await Task.sleep(seconds: removalAnimationDuration)
        isAppeared = false
      }
    }
  }

  internal func startRemovalTask(for model: ToastModel) async {
    if let duration = model.value.duration {
      do {
        try await Task.sleep(seconds: duration)
        remove(model)
      } catch {}
    }
  }

  @discardableResult
  internal func append<V>(
    message: String,
    task: sending () async throws -> sending V,
    onSuccess: (V) -> ToastValue,
    onFailure: (any Error) -> ToastValue
  ) async throws -> sending V {
    let model = append(ToastValue(icon: LoadingView(), message: message, duration: nil))
    do {
      let value = try await task()
      // Inline rather than through `update`: passing the toast to a method would tie `value` to the main actor.
      let successToast = onSuccess(value)
      withAnimation(.spring(duration: 0.3)) {
        model.value = successToast
      }
      announceToAccessibility(accessibilityText(for: successToast))
      return value
    } catch {
      update(model, to: onFailure(error))
      throw error
    }
  }

  /// Swaps a visible toast's value with animation, announcing it unless VoiceOver would say the same again.
  private func update(_ model: ToastModel, to value: ToastValue) {
    let spoken = accessibilityText(for: value)
    let unchanged = spoken == accessibilityText(for: model.value)
    withAnimation(.spring(duration: 0.3)) {
      model.value = value
    }
    if !unchanged { announceToAccessibility(spoken) }
  }
}

internal func accessibilityText(for toast: ToastValue) -> String {
  if let message = toast.accessibilityMessage { return message }
  return [toast.message, toast.detail].compactMap { $0 }.joined(separator: ". ")
}

internal let removalAnimationDuration: Double = 0.3
