//
//  ContentView.swift
//  ultra_sound2
//
//  Created by Кирилл on 23.08.2021.
//

import SwiftUI

struct Wave: Shape {
    var strength: Double
    var frequency: Double
    var phase: Double
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midWidth = width / 2
        let midHeight = height / 2
        let wavelength = width / frequency
        let oneOverMidWidth = 1 / midWidth
        
        path.move(to: CGPoint(x: 0, y: midHeight * 1.5))
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let distanceFromMidWidth = x - midWidth
            let normalDistance = oneOverMidWidth * distanceFromMidWidth
            let parabola = -(normalDistance * normalDistance) + 1
            let sine = sin(relativeX + phase)
            let y = parabola * strength * sine + midHeight * 1.5
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return Path(path.cgPath)
    }
}

struct ContentView: View {
    @State private var phase = 0.0
    @State private var value: CGPoint = CGPoint(x: 0, y: 0)
    @State private var start = true
    var initialCenter = CGPoint()
    let myUnit = ToneOutputUnit()
    
    func button()
    {
        if (self.start)
        {
            myUnit.setFrequency(freq: Double(self.value.y))
            myUnit.enableSpeaker()
            myUnit.setToneTime(t: 20000)
            self.start = false
        }
        else
        {
            self.start = true
            myUnit.stop()
        }
    }
    var simpleDrag: some Gesture {
            DragGesture()
                .onChanged { value in
                    self.value = CGPoint(x: self.value.x + (value.location.x - value.startLocation.x), y: self.value.y + ((value.startLocation.y - value.location.y) / 5))
                    self.myUnit.setFrequency(freq: Double(self.value.y))
                }
                .onEnded{ value in
                    
                    self.value = CGPoint(x: self.value.x + (value.location.x - value.startLocation.x), y: self.value.y + ((value.startLocation.y - value.location.y) / 5))
                    myUnit.setFrequency(freq: Double(self.value.y))
                }
        }
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 100){
            Spacer()
            Spacer()
            Spacer()
        Text("\(Int(value.y))")
            .foregroundColor(.white)
            .font(.largeTitle)
            
        ZStack {
                        ForEach(4..<8) { i in
                        let x = 800 / (i * i)
                            Wave(strength: Double(x), frequency: Double(self.value.y) / 500 , phase: self.phase)
                            .stroke(Color.white, lineWidth: 2)
                    }
                
        }
            
            Button(action: {self.button()})
            {
                start ? Text("Start") .foregroundColor(.white) : Text("Stop")
                    .foregroundColor(.white)
            }
            .padding(.leading, 100)
            .padding(.trailing, 100)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color.init(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
            .font(.largeTitle)
            Spacer()
        }
        .background(Color.init(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                self.phase = -.pi * 2
            }
        }
        .gesture(
            simpleDrag
        )
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
}
