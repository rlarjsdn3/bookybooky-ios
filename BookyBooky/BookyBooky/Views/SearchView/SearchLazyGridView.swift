//
//  SearchLazyGridView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/03/31.
//

import SwiftUI
import AlertToast

struct SearchLazyGridView: View {
    
    // MARK: - PROPERTIES
    
    @Binding var listTypeSelected: BookListTabItem
    @Binding var scrollYOffset: CGFloat
    
    @State private var startOffset: CGFloat = 0.0
    
    var bookListItems: [BookList.Item] {
        switch listTypeSelected {
        case .bestSeller:
            return bookViewModel.bestSeller
        case .itemNewAll:
            return bookViewModel.itemNewAll
        case .itemNewSpecial:
            return bookViewModel.itemNewSpecial
        case .blogBest:
            return bookViewModel.blogBest
        }
    }
    
    var columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - WRAPPER PROPERTIES
    
    @EnvironmentObject var bookViewModel: AladinAPIManager
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            Color("Background")
            
            if !bookListItems.isEmpty {
                ScrollViewReader { proxy in
                    scrollLazyGridCells(scrollProxy: proxy)
                }
            } else {
                VStack {
                    noResultsLabel
                    
                    refreshButton
                }
            }
        }
    }
}

// MARK: - EXTENSIONS

extension SearchLazyGridView {
    var lazyGridCells: some View {
        LazyVGrid(columns: columns, spacing: 25) {
            ForEach(bookListItems, id: \.self) { item in
                ListTypeCellView(bookItem: item)
            }

        }
        .overlay(alignment: .top) {
            GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    let offset = proxy.frame(in: .global).minY
                    if startOffset == 0 {
                        self.startOffset = offset
                    }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scrollYOffset = startOffset - offset
                    }
                    print(scrollYOffset)
                }
                return Color.clear
            }
            .frame(width: 0, height: 0)
        }
        // 하단 사용자화 탭 뷰가 기본 탭 뷰와 높이가 상이하기 때문에 위/아래 간격을 달리함
        .padding(.top, 20)
        .padding(.bottom, 40)
        .padding(.horizontal, 10)
        .id("Scroll_To_Top")
    }
    
    var noResultsLabel: some View {
        VStack(spacing: 5) {
            Text("도서 정보 불러오기 실패")
                .font(.title2)
                .fontWeight(.bold)

            Text("잠시 후 다시 시도하십시오.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 0)
    }
    
    var refreshButton: some View {
        Button("다시 불러오기") {
            for type in BookListTabItem.allCases {
                bookViewModel.requestBookListAPI(type: type)
            }
            Haptics.shared.play(.rigid)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

extension SearchLazyGridView {
    @ViewBuilder
    func scrollLazyGridCells(scrollProxy proxy: ScrollViewProxy) -> some View {
        ScrollView(showsIndicators: false) {
            lazyGridCells
        }
        // 도서 리스트 타입이 변경될 때마다 리스트의 스크롤을 맨 위로 올림
        .onChange(of: listTypeSelected) { _ in
            withAnimation {
                proxy.scrollTo("Scroll_To_Top", anchor: .top)
            }
        }
    }
}

// MARK: - PREVIEW

struct SearchLazyGridView_Previews: PreviewProvider {
    static var previews: some View {
        SearchLazyGridView(listTypeSelected: .constant(.bestSeller), scrollYOffset: .constant(0.0))
            .environmentObject(AladinAPIManager())
    }
}
