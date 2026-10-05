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
    let model = ToastModel(value: toast)
    models.append(model)
    announceToAccessibility(accessibilityText(for: toast))
    return model
  }

  internal func remove(_ model: ToastModel) {
    if let index = self.models.firstIndex(where: { $0 === model }) {
      self.models.remove(at: index)
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
      let successToast = onSuccess(value)
      withAnimation(.spring(duration: 0.3)) {
        model.value = successToast
      }
      announceToAccessibility(accessibilityText(for: successToast))
      return value
    } catch {
      let failureToast = onFailure(error)
      withAnimation(.spring(duration: 0.3)) {
        model.value = failureToast
      }
      announceToAccessibility(accessibilityText(for: failureToast))
      throw error
    }
  }
}

private func accessibilityText(for toast: ToastValue) -> String {
  [toast.message, toast.detail].compactMap { $0 }.joined(separator: ". ")
}

internal let removalAnimationDuration: Double = 0.3
