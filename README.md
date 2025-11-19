#  FitCount by QuickPose.ai

This project provides the end-to-end demo solution for an AR/AI fitness iOS app. FitCount is based on the [QuickPose.ai](https://QuickPose.ai) SDK.

For more explanation of the code in this repository please check our [FitCount Guide](https://docs.quickpose.ai/docs/MobileSDK/Guides/FitCount%20Guide)

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
* **Custom Exercise Engine** - Create your own exercises with custom angle ranges and stages
* Understand if a user is present on the screen with .inside feature
* Audio and text [feedback and guidance](https://docs.quickpose.ai/docs/MobileSDK/Features/Feedback).
* Instructions before the workout.
* Local workout history.

## Custom Exercises

FitCount includes a powerful custom exercise system that allows you to create exercises beyond the built-in QuickPose exercises. Custom exercises use angle ranges and exercise stages to track complex movements.

### Available Custom Exercises

The app includes three pre-built custom exercises:

1. **Side Tilts** (`SideTiltsExercise.swift`) - Lateral bending exercise with alternating arm movements
2. **Knee Raises** (`KneeRaisesExercise.swift`) - Alternating knee raises with arm position tracking
3. **Front Push-up** (`FrontPushupExercise.swift`) - Push-up tracking with top and bottom position detection

### How Custom Exercises Work

Custom exercises are defined using:

- **Exercise Stages**: Sequential positions that define one complete repetition
- **Joint Angles**: Specific angle ranges (min/max) for joints like elbows, shoulders, knees, and hips
- **Range of Motion Tracking**: QuickPose features that track joint movements
- **Feedback System**: Optional real-time feedback for correct form

Each custom exercise cycles through its stages, and when all stages are completed, a rep is counted.

### Creating Your Own Custom Exercise

To create a new custom exercise:

1. Create a new Swift file following the naming pattern: `[ExerciseName]Exercise.swift`
2. Define your exercise stages with joint angle requirements:

```swift
class MyCustomExercise {
    static func createExercise(hideFeedback: Bool = true) -> CustomExercise {
        let stages = [
            ExerciseStage(
                id: "stage_1",
                name: "Stage 1",
                requirements: [
                    .elbow(side: .right): AngleRange(min: 160, max: 210),
                    .knee(side: .right): AngleRange(min: 150, max: 200)
                ],
                description: "Description of this stage"
            ),
            // Add more stages...
        ]
        
        let requiredFeatures: [QuickPose.Feature] = [
            .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true), style: lightOverlayStyle),
            // Add required features...
        ]
        
        return CustomExercise(
            id: "my_exercise",
            name: "My Exercise",
            description: "Exercise description",
            stages: stages,
            requiredFeatures: requiredFeatures,
            hideFeedback: hideFeedback
        )
    }
}
```

3. Register your exercise in `QuickPoseBasicView.swift` in the `.introExercise` case:

```swift
else if sessionConfig.exercise.name == "My Exercise" {
    customExerciseEngine = CustomExerciseEngine(exercise: MyCustomExercise.createExercise())
}
```

### Tips for Custom Exercises

- **Use 2 stages for simple repetitive exercises** (like push-ups: top position → bottom position)
- **Use 4+ stages for alternating exercises** (like knee raises: start → right knee up → center → left knee up)
- **Test angle ranges** by checking the overlay feedback during exercise execution
- **Set hideFeedback: false** during development to see real-time angle feedback
- Make sure angle ranges have enough tolerance (typically 40-60 degrees) to account for natural variation

## Add AI fitness coach to your app using QuickPose.ai SDK

1. Register for a free SDK key at our [Development portal](https://dev.quickpose.ai/auth/signup).
2. Check out our [GitHub Repository](https://github.com/quickpose/quickpose-ios-sdk) and [Getting Started Guide](https://docs.quickpose.ai/docs/MobileSDK/GettingStarted/Integration).
