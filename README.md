# Toasts

A toast notification library for SwiftUI.

![Simulator Screen Recording - iPhone 15 Pro - 2024-09-16 at 11 53 37](https://github.com/user-attachments/assets/7b11b2f1-ed6e-4955-a674-c3bfd49ab8ad)

![Simulator Screen Recording - iPhone 16 Pro - 2024-09-18 at 10 53 57](https://github.com/user-attachments/assets/6c5f4906-aab6-4ef6-b9bb-844d7110586b)

<img width="341" alt="SCR-20240916-kqog" src="https://github.com/user-attachments/assets/c072c767-8e26-471b-b156-80b204ca433b">

## Features

- Easy-to-use toast notifications
- Support for custom icons, messages, and buttons
- Seamless integration with SwiftUI
- Dark mode support
- Slide gesture to dismiss
- Loading state interface with async/await
- Full VoiceOver compatibility for inclusive user experience
- Optional second line and an environment-driven `ToastStyle` (fork additions, see [Styling](#styling))

## Usage

1. Install toast in your root view:

```swift
import SwiftUI
import Toasts

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .installToast(position: .bottom)
    }
  }
}
```

2. Present a toast:

```swift
@Environment(\.presentToast) var presentToast

Button("Show Toast") {
  let toast = ToastValue(
    icon: Image(systemName: "bell"),
    message: "You have a new notification."
  )
  presentToast(toast)
}
```

## Advanced Usage

```swift
presentToast(
  message: "Loading...",
  task: {
    // Handle loading task
    return "Success"
  },
  onSuccess: { result in
    ToastValue(icon: Image(systemName: "checkmark.circle"), message: result)
  },
  onFailure: { error in
    ToastValue(icon: Image(systemName: "xmark.circle"), message: error.localizedDescription)
  }
)
```

## Customization

<img width="356" alt="image" src="https://github.com/user-attachments/assets/937ef007-cbe7-4462-963c-2fb92a6cd844">

- **Remove icon**

```swift
let toast = ToastValue(
  message: "Message only toast."
)
```

- **Add button**

```swift
let toast = ToastValue(
  message: "Toast with action required.",
  button: ToastButton(title: "Confirm", color: .green, action: {
    // Handle button action
  })
)
```

## Styling

> This fork adds `ToastStyle` and `ToastValue.detail`. With neither used, toasts look and behave exactly like 1.1.2.

Style every toast once, after `installToast`:

```swift
ContentView()
  .installToast(position: .top)
  .toastStyle(ToastStyle(
    messageFont: .headline,
    messageColor: .white,
    detailFont: .footnote,
    detailColor: .gray,
    buttonFont: .headline.bold(),
    background: Color(white: 0.14),
    buttonBackground: .white.opacity(0.12),
    cornerRadius: nil,                 // nil = capsule
    shadow: .init(color: .black.opacity(0.5), radius: 16, y: 12),
    height: 48,                        // single line; the minimum height with a detail line
    detailVerticalPadding: 8,
    edgeSpacing: 6,                    // gap to the safe area on the positioned edge; default 16
    messageTracking: -0.32,
    buttonTracking: -0.32,
    leadingPadding: 20,                // before the icon or message; default 15 / 14
    buttonHeight: 34,                  // default: fills the toast less 10pt above and below
    buttonHorizontalPadding: 14,       // default 9
    buttonMinWidth: 0,                 // default 64
    buttonLeadingPadding: 4,           // default 0
    buttonTrailingPadding: 7,          // default 10
    iconSize: 20,                      // default 19
    iconLeadingPadding: 16,            // default: leadingPadding, else 15
    trailingPadding: 20                // after the message when there is no button; default 14
  ))
```

Every field is optional; `nil` keeps the built-in value. Add a second line with `detail`:

```swift
presentToast(ToastValue(
  message: "Card hidden",
  detail: "Sign in any time from the profile button",
  button: ToastButton(title: "Undo", color: .white) { /* … */ }
))
```

A toast without a detail line keeps its fixed height; one with a detail grows to fit it.

## Replace, VoiceOver text and dismissal (1.4.0)

All three are optional `ToastValue` parameters; leave them out and nothing changes.

```swift
presentToast(ToastValue(
  message: "Saving… 40%",
  accessibilityMessage: "Saving, forty percent",  // spoken instead of message/detail
  key: "upload",                                  // same key as a visible toast: update it, don't stack
  onDismiss: { /* … */ }                          // once, when the toast is removed
))
```

- `key`: presenting a value whose non-nil `key` matches a visible toast updates that toast in place (message, detail, icon, button, duration, accessibility text), restarts its timer and announces the new text. With no match, or a `nil` key, a new toast is added as before.
- `onDismiss`: called once when the toast goes away (its timer or a swipe). A replace keeps the same toast: the new value's `onDismiss` is used if it has one, otherwise the earlier one is kept, and it fires on removal.

## Custom SafeArea Handling

If you need to manually control the safe area insets for toasts (e.g., in a custom view hierarchy or when using multiple tabs), you can use the `addToastSafeAreaObserver` modifier:

```swift
struct ContentView: View {
  var body: some View {
    TabView {
      Tab1View()
      Tab2View()
    }
  }
}

struct Tab1View: View {
  var body: some View {
    ScrollView {
      // Your content here
    }
    .addToastSafeAreaObserver()
  }
}
```

This modifier helps the toast system correctly detect and respond to safe area changes, which is particularly useful in complex view hierarchies or when using TabView.

## Requirements

- iOS 14.0+
- Swift 6.1+
- Xcode 16.4+

## Credits

Toasts is by [sunghyun-k](https://github.com/sunghyun-k/swiftui-toasts), MIT licensed (see `LICENSE.md`). This fork
([boredarthur/swiftui-toasts](https://github.com/boredarthur/swiftui-toasts)) adds `ToastStyle`, `ToastValue.detail`, `accessibilityMessage`, `key` and `onDismiss`
and keeps everything else as it was.
