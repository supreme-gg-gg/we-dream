import SwiftUI

struct circleview: View {
    // 状态变量用于跟踪起始和终止角度及其对应的进度
    @State var startAngle: Double = 0
    @State var toAngle: Double = 180
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5
    
    @State private var lastAngle: Double? = nil  // 用于跟踪拖动过程中的上一次角度
    
    var body: some View {
        ZStack {
            // 背景颜色设置
            Color(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let radius = (min(width, height)) / 2
                ZStack {
                    
                    // 构建表盘背景，每3度一个刻度，每5个刻度加粗
                    ForEach(1...120, id: \.self) { index in
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 2, height: index % 5 == 0 ? 15 : 5)
                            .offset(y: (width - 60) / 2)
                            .rotationEffect(.init(degrees: Double(index) * 3))
                    }
                    // 数字标记，每2小时一个标记
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
                    // 外圆环边框
                    Circle()
                        .stroke(.black, lineWidth: 55)
                    // 可动态调整的圆环部分
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
                    ForEach(0..<100, id: \.self) { index in
                        Rectangle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 2, height: 15)
                            .cornerRadius(2)
                            .offset(y: -radius)
                            .rotationEffect(.degrees(Double(index) * 3.6))
                            .opacity(shouldShowLine(index: index) ? 1 : 0)
                    }
                    
                    // 开始和结束拖动图标
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
                // 显示睡眠和起床时间
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
                // 显示时间差
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
    
    func shouldShowLine(index: Int) -> Bool {
            let progress = CGFloat(index) / 100
            if startProgress > toProgress {
                // 跨越0点的情况
                return progress >= startProgress || progress <= toProgress
            } else {
                // 正常情况
                return progress >= startProgress && progress <= toProgress
            }
        }
    
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
    
    func endDragProgress() {
        lastAngle = nil
    }
    
    func onDragProgress(value: DragGesture.Value) {
        // 计算视图的中心点，这需要根据你的视图尺寸来调整
        let width = UIScreen.main.bounds.width // 仅为示例，根据实际情况调整
        let center = CGPoint(x: width / 2, y: width / 2)
        
        // 计算当前触摸点相对于中心点的向量
        let currentVector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
        
        // 当前触摸点的角度
        let currentAngle = atan2(currentVector.dy, currentVector.dx) * 180 / .pi
        
        // 如果这是拖动的开始，初始化lastAngle
        if lastAngle == nil {
            lastAngle = currentAngle
        }
        
        // 计算角度差
        let angleDifference = currentAngle - lastAngle!
        
        // 应用角度差更新角度
        startAngle = (startAngle + angleDifference).truncated(to: 360)
        toAngle = (toAngle + angleDifference).truncated(to: 360)
        
        // 更新进度
        startProgress = startAngle / 360
        toProgress = toAngle / 360
        
        lastAngle = currentAngle
    }
    
    
    func getTime(angle: Double) -> Date {
        // 角度转换为24小时制小时数，每15度表示一个小时
        var hour = Int(angle / 15)
        // 获取小时数后的剩余角度，并计算分钟数（每度对应4分钟）
        var minute = Int((angle.truncatingRemainder(dividingBy: 15)) * 4)
        // 四舍五入到最近的5的倍数
        minute = (minute + 2) / 5 * 5  // 添加2是为了确保正确四舍五入
        
        // 如果分钟数计算结果为60，将其调整为0，并且小时数加1（特别处理24点的情况）
        if minute == 60 {
            minute = 0
            hour = (hour + 1) % 24
        }
        // DateFormatter设置为24小时制
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"  // 使用大写的"HH"来表示24小时制
        
        // 根据计算出的小时和分钟构造时间字符串，并尝试转换为Date类型
        if let date = formatter.date(from: "\(hour):\(minute):00") {
            return date
        }
        
        return formatter.date(from: "00:00:00") ?? .init()  // 如果转换失败，返回当前时间
    }
    
    
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

extension Double {
    /// 将角度值截断到指定的范围内。
    /// - Parameter degrees: 指定的范围，通常是 360 度。
    /// - Returns: 截断后的角度值，范围在 0 到指定的 degrees 之间。
    func truncated(to degrees: Double) -> Double {
        // 将角度值取模，得到一个新的角度值 newAngle。
        // 这个值在 -degrees 到 degrees 之间。
        let newAngle = self.truncatingRemainder(dividingBy: degrees)
        // 如果 newAngle 小于 0，则加上 degrees，使其变为正值。
        // 例如，如果 newAngle 是 -90，且 degrees 是 360，那么返回值将是 270。
        return newAngle < 0 ? newAngle + degrees : newAngle
    }
}

#Preview {
    circleview()
}
