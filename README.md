#  FitCount by QuickPose.ai

This project provides the end-to-end demo solution for an AR/AI fitness iOS app. FitCounter is based on the [QuickPose.ai](https://QuickPose.ai) SDK.

Try the **TestFlight version of the FitCount app**: https://testflight.apple.com/join/4fDEDysS.

## How to run the project
1. Clone the repository.
2. Register for a free SDK key at our [Development portal](https://dev.quickpose.ai/auth/signup).
3. Open the project in Xcode.
4. Add your SDK key to the `Workout/QuckPoseBasicView.swift` file to this line:

```swift
private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY") // register for your free key at https://dev.quickpose.ai
```
5. Run the project on your physical device. Note that due to the Apple's limitations, the SDK will not work on the simulator.

## Supported features

* Counting fitness exercises ([Squats](https://docs.quickpose.ai/docs/MobileSDK/Features/Exercises/Squats), [Bicep Curls](https://docs.quickpose.ai/docs/MobileSDK/Features/Exercises/Bicep%20Curls)) repetitions based on user's movement.
* Understand if a user is present on the screen with .inside feature
* Audio and text [feedback and guidance](https://docs.quickpose.ai/docs/MobileSDK/Features/Feedback).
* Instructions before the workout.
* Local workout history.

## Add AI fitness coach to your app using QuickPose.ai SDK

1. Register for a free SDK key at our [Development portal](https://dev.quickpose.ai/auth/signup).
2. Check out our [GitHub Repository](https://github.com/quickpose/quickpose-ios-sdk) and [Getting Started Guide](https://docs.quickpose.ai/docs/MobileSDK/GettingStarted/Integration).