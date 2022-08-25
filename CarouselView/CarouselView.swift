//
//  CarouselView.swift
//  CarouselView
//
//  Created by kazunori.aoki on 2022/08/24.
//

import SwiftUI
import Combine

struct CarouselView<Content: View, T: Any>: View {
    
    // MARK: Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: Property
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    @State private var selectedTab: Int = 1
    
    // MARK: Initialize
    private let data: [T]
    private let isUseTimer: Bool
    private let seconds: Double
    private let content: (T) -> Content
    private let showAlternativeBanner: Bool
    private let height: CGFloat
    private let horizontalPadding: CGFloat
    private let cornerRadius: CGFloat
    private let transition: TransitionType
    
    init(data: [T],
         isUseTimer: Bool = true,s
         secondsDisplayingBanner: Double = 3,
         height: CGFloat = 150,
         horizontalPadding: CGFloat = 30,
         cornerRadius: CGFloat = 10,
         transition: TransitionType = .scale,
         @ViewBuilder content: @escaping (T) -> Content)
    {
        var modifiedData = data
        if let firstElement = data.first, let lastElement = data.last {
            modifiedData.append(firstElement)
            modifiedData.insert(lastElement, at: 0)
            showAlternativeBanner = false
        } else {
            showAlternativeBanner = true
        }
        
        self._timer = .init(initialValue: Timer.publish(every: secondsDisplayingBanner, on: .main, in: .common))
        self.data = modifiedData
        self.isUseTimer = isUseTimer
        self.content = content
        self.seconds = secondsDisplayingBanner
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.transition = transition
    }
    

    // MARK: View
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Array(zip(data.indices, data)), id: \.0) { index, item in
                GeometryReader { geometry in
                    let positionMinX = geometry.frame(in: .global).minX

                    content(item)
                        .cornerRadius(cornerRadius)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .rotation3DEffect(transition == .rotation3D ? getRotation(positionMinX) : .degrees(0),
                                          axis: (x: 0, y: 1, z: 0))
                        .opacity(transition == .opacity ? getValue(positionMinX) : 1)
                        .scaleEffect(transition == .scale ? getValue(positionMinX) : 1)
                        .padding(.horizontal, horizontalPadding)
                        .onChange(of: positionMinX) { offset in
                            if isUseTimer {
                                if offset != 0 {
                                    stopTimer()
                                }
                                if offset == 0 {
                                    startTimer()
                                }
                            }
                        }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
        .onChange(of: selectedTab) { newValue in

            if showAlternativeBanner {
                guard newValue < data.count else {
                    withAnimation {
                        selectedTab = 0
                    }
                    return
                }
            } else {

                if newValue == 0 {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                          selectedTab = data.count - 2
                      }
                  }

                  if newValue == data.count - 1 {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                          selectedTab = 1
                      }
                  }
            }
        }
        .onAppear(perform: startTimer)
        .onReceive(timer) { _ in
            if isUseTimer {
                withAnimation {
                    selectedTab += 1
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            if isUseTimer {
                switch newValue {
                case .active:
                    startTimer()
                case .background, .inactive:
                    stopTimer()
                default:
                    break
                }
            }
        }
    }
}

extension CarouselView {

    private func getRotation(_ positionX: CGFloat) -> Angle {
        return .degrees(positionX / -10)
    }

    private func getValue(_ positionX: CGFloat) -> CGFloat {
        return 1 - abs(positionX / UIScreen.main.bounds.width)
    }

    private func startTimer() {
        guard cancellable == nil, isUseTimer else { return }

        timer = Timer.publish(every: seconds, on: .main, in: .common)
        cancellable = timer.connect()
    }

    private func stopTimer() {
        guard cancellable == nil else { return }

        cancellable?.cancel()
        cancellable = nil
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(data: ["1", "2", "3", "4"]) { element in
            Text(element)
                .font(.title.bold())
                .padding()
                .background(Color.green)
        }
    }
}
