//
//  ContentView.swift
//  CarouselView
//
//  Created by kazunori.aoki on 2022/08/24.
//

import SwiftUI

// ref: https://github.com/dancarvajc/SwiftUI-Infinite-Carousel/blob/main/Sources/SwiftUIInfiniteCarousel/InfiniteCarousel.swift

struct ContentView: View {
    var body: some View {
        CarouselView(data: ["1", "2", "3", "4"], isUseTimer: false) { element in
            Text(element)
                .font(.title.bold())
                .padding()
                .background(Color.green)
        }
    }
}

