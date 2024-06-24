import SwiftUI

struct SliderView: View {
    // State variables to track the start and end angles, and their corresponding progress.
    @State var startAngle: Double = 0
    @State var toAngle: Double = 180
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5
    
    @State private var lastAngle: Double? = nil  // Tracks the previous angle during dragging
    
    var body: some View {
        ZStack {
            // Background color
            Color(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let radius = (min(width, height)) / 2
                ZStack {
                    
                    // Creating the clock background with ticks every 3 degrees and bold ticks every 5 ticks
                    ForEach(1...120, id: \.self) { index in
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 2, height: index % 5 == 0 ? 15 : 5)
                            .offset(y: (width - 60) / 2)
                            .rotationEffect(.init(degrees: Double(index) * 3))
                    }
                    // Number markers every 2 hours
                    ForEach(1...24, id: \.self) { index in
                        ZStack {
                            if index % 2 == 0 {
                                Text("\(index == 24 ? 0 : index)")
                                    .font(.callout.bold())
                                    .foregroundColor(index % 6 == 0 ? .white : .gray)
                                    .rotationEffect(.init(degrees: Double(-180 - index * 15)))
                                    .offset(y: (width - 100) / 2)
                                    .rotationEffect(.init(degrees: Double(index) * 15))
                            }
                        }
                        .rotationEffect(.init(degrees: -180))
                    }
                    // Outer circle border
                    Circle()
                        .stroke(.black, lineWidth: 55)
                    // Adjustable part of the circle
                    let reverseRotation = (startProgress > toProgress) ? -Double((1 - startProgress) * 360) : 0
                    Circle()
                        .trim(from: startProgress > toProgress ? 0 : startProgress, to: toProgress + (-reverseRotation / 360))
                        .stroke(.orange, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.init(degrees: -90))
                        .rotationEffect(.init(degrees: reverseRotation))
                        .gesture(DragGesture()
                            .onChanged({ value in
                                onDragProgress(value: value)
                            })
                                .onEnded({ value in
                                    endDragProgress()
                                })
                        )
                    // Ticks for progress indicators
                    ForEach(0..<100, id: \.self) { index in
                        Rectangle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 2, height: 15)
                            .cornerRadius(2)
                            .offset(y: -radius)
                            .rotationEffect(.degrees(Double(index) * 3.6))
                            .opacity(shouldShowLine(index: index) ? 1 : 0)
                    }
                    
                    // Start and end drag icons
                    Image(systemName: "bed.double.fill")
                        .font(.callout)
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                        .rotationEffect(.init(degrees: 90))
                        .rotationEffect(.init(degrees: -startAngle))
                        .background(.black, in: .circle)
                        .offset(x: width / 2)
                        .rotationEffect(.init(degrees: startAngle))
                        .gesture(DragGesture().onChanged({ value in
                            onDrag(value: value, fromSlider: true)
                        }))
                        .rotationEffect(.init(degrees: -90))
                    
                    Image(systemName: "alarm.fill")
                        .font(.callout)
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                        .rotationEffect(.init(degrees: 90))
                        .rotationEffect(.init(degrees: -toAngle))
                        .background(.black, in: .circle)
                        .offset(x: width / 2)
                        .rotationEffect(.init(degrees: toAngle))
                        .gesture(
                            DragGesture().onChanged({ value in
                                onDrag(value: value)
                            }))
                        .rotationEffect(.init(degrees: -90))
                }
                
            }
            .padding(70)
            .padding(.top, 100)
            
            VStack {
                // Display bedtime and wake-up time
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.orange)
                            Text("BEDTIME")
                                .foregroundColor(Color(uiColor: .systemGray3))
                        }
                        Text(getTime(angle: startAngle).formatted(date: .omitted, time: .shortened))
                            .font(.title2.bold())
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "alarm.fill")
                                .foregroundColor(.green)
                            Text("WAKE UP")
                                .foregroundColor(Color(uiColor: .systemGray3))
                        }
                        Text(getTime(angle: toAngle).formatted(date: .omitted, time: .shortened))
                            .font(.title2.bold())
                    }
                }
                // Display time difference
                HStack {
                    Text("\(getTimeDifference().0) h" + "  \(getTimeDifference().1) min")
                        .font(.title2.bold())
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(15)
                .padding(.top)
            }
            .padding(.horizontal, 70)
            .padding(.top, 230)
            .foregroundColor(.white)
        }
        .ignoresSafeArea()
    }
    
    // Determine whether a line should be displayed at a given index
    func shouldShowLine(index: Int) -> Bool {
        let progress = CGFloat(index) / 100
        if startProgress > toProgress {
            // Case where the angle crosses the 0-degree point
            return progress >= startProgress || progress <= toProgress
        } else {
            // Normal case
            return progress >= startProgress && progress <= toProgress
        }
    }
    
    // Handle dragging events for angle and progress updates
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        var angle = radians * 180 / .pi
        if angle < 0 {
            angle = 360 + angle
        }
        let progress = angle / 360
        if fromSlider {
            startAngle = angle
            startProgress = progress
        } else {
            toAngle = angle
            toProgress = progress
        }
    }
    
    // Reset the lastAngle when drag ends
    func endDragProgress() {
        lastAngle = nil
    }
    
    // Handle dragging progress updates
    func onDragProgress(value: DragGesture.Value) {
        // Calculate the center of the view, adjust according to your view size
        let width = UIScreen.main.bounds.width // Just an example, adjust as needed
        let center = CGPoint(x: width / 2, y: width / 2)
        
        // Calculate the vector from the center to the current touch point
        let currentVector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
        
        // Calculate the angle of the current touch point
        let currentAngle = atan2(currentVector.dy, currentVector.dx) * 180 / .pi
        
        // Initialize lastAngle if this is the start of a drag
        if lastAngle == nil {
            lastAngle = currentAngle
        }
        
        // Calculate the difference in angles
        let angleDifference = currentAngle - lastAngle!
        
        // Apply the angle difference to update the angles
        startAngle = (startAngle + angleDifference).truncated(to: 360)
        toAngle = (toAngle + angleDifference).truncated(to: 360)
        
        // Update the progress
        startProgress = startAngle / 360
        toProgress = toAngle / 360
        
        lastAngle = currentAngle
    }
    
    // Convert an angle to a time
    func getTime(angle: Double) -> Date {
        // Convert angle to hour in a 24-hour format, every 15 degrees is an hour
        var hour = Int(angle / 15)
        // Get the remaining degrees after calculating hours, convert to minutes (4 minutes per degree)
        var minute = Int((angle.truncatingRemainder(dividingBy: 15)) * 4)
        // Round to the nearest multiple of 5
        minute = (minute + 2) / 5 * 5  // Adding 2 ensures proper rounding
        
        // If minutes result in 60, adjust to 0 and add 1 to the hour (special case for 24:00)
        if minute == 60 {
            minute = 0
            hour = (hour + 1) % 24
        }
        // DateFormatter set to 24-hour format
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"  // Use uppercase "HH" for 24-hour format
        
        // Create a time string from the calculated hour and minutes, try converting to Date type
        if let date = formatter.date(from: "\(hour):\(minute):00") {
            return date
        }
        
        return formatter.date(from: "00:00:00") ?? .init()  // Return current time if conversion fails
    }
    
    // Get the difference between start and end times
    func getTimeDifference() -> (Int, Int) {
        
        let calendar = Calendar.current
        let result = calendar.dateComponents([.hour, .minute], from: getTime(angle: startAngle), to: getTime(angle: toAngle))
        var hour = (result.hour ?? 0) < 0 ? (result.hour ?? 0) + 24 : (result.hour ?? 0)
        var minute = (result.minute ?? 0) < 0 ? (result.minute ?? 0) + 60 : (result.minute ?? 0)
        if (result.hour ?? 0 < 0 && minute > 0) {
            hour -= 1
        }
        if (hour == 0 && (result.minute ?? 0) < 0) {
            hour = 23
        }
        if (hour == 0 && minute == 0) {
            hour = 24
            minute = 0
        }
        return (hour, minute)
    }
}

// Extension to truncate angle values to a specified range
extension Double {
    /// Truncate an angle value to a specified range.
    /// - Parameter degrees: The specified range, typically 360 degrees.
    /// - Returns: The truncated angle value, within the range of 0 to the specified degrees.
    func truncated(to degrees: Double) -> Double {
        // Use modulus to get a new angle value within -degrees to degrees.
        let newAngle = self.truncatingRemainder(dividingBy: degrees)
        // If the new angle is less than 0, add degrees to make it positive.
        // For example, if newAngle is -90 and degrees is 360, the return value will be 270.
        return newAngle < 0 ? newAngle + degrees : newAngle
    }
}

#Preview {
    SliderView()
}
