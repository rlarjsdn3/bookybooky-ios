//
//  SearchSheetScrollView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/03/31.
//

import SwiftUI

struct SearchSheetScrollView: View {
    
    // MARK: - WRAPPER PROPERTIES
    
    @EnvironmentObject var aladinAPIManager: AladinAPIManager
    
    @State private var isPresentingSearchInfoView = false
    
    // MARK: - PROPERTIES
    
    @Binding var searchQuery: String
    @Binding var searchIndex: Int
    @Binding var selectedListMode: ListMode
    @Binding var selectedCategory: CategoryType
    
    // MARK: - COMPUTED PROPERTIES
    
    // 선택된 도서 카테고리에 맞게 리스트를 필터링한 결과를 반환하는 프로퍼티
    var filteredSearchItems: [briefBookInfo.Item] {
        var list: [briefBookInfo.Item] = []
        
        if selectedCategory == .all {
            return aladinAPIManager.searchResults
        } else {
            for item in aladinAPIManager.searchResults
                where item.categoryName.refinedCategory == selectedCategory {
                list.append(item)
            }
        }
        
        return list
    }
    
    // MARK: - BODY
    
    var body: some View {
        searchSheetScroll
    }
}

// MARK: - EXTENSIONS

extension SearchSheetScrollView {
    var searchSheetScroll: some View {
        Group {
            if aladinAPIManager.searchResults.isEmpty {
                noResultLabel
            } else {
                scrollSearchBooks
            }
        }
    }
    
    var scrollSearchBooks: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                switch selectedListMode {
                case .grid:
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 25) {
                        ForEach(filteredSearchItems, id: \.self) { book in
                            SearchSheetGridBookButton(bookItem: book)
                        }
                    }
                    .safeAreaPadding()
                    .id("Scroll_To_Top")
                case .list:
                    searchSheetCellButtons
                }
                
                seeMoreButton
            }
            .onChange(of: searchIndex) { _ in
                // 새로운 검색을 시도할 때만 도서 스크롤을 제일 위로 올립니다.
                // '더 보기' 버튼을 클릭해도 도서 스크롤이 이동하지 않습니다.
                if searchIndex == 1 {
                    withAnimation {
                        scrollProxy.scrollTo("Scroll_To_Top", anchor: .top)
                    }
                }
            }
            .onChange(of: selectedCategory) { _ in
                withAnimation {
                    scrollProxy.scrollTo("Scroll_To_Top", anchor: .top)
                }
            }
        }
    }
    
    var searchSheetCellButtons: some View {
        LazyVStack {
            ForEach(filteredSearchItems, id: \.self) { item in
                SearchSheetListBookButton(item)
            }
            .id("Scroll_To_Top")
        }
    }
    
    var seeMoreButton: some View {
        Button {
            searchIndex += 1
            aladinAPIManager.requestBookSearchAPI(
                searchQuery,
                page: searchIndex
            )
        } label: {
            Text("더 보기")
                .font(.title3)
                .fontWeight(.bold)
                .frame(
                    width: mainScreen.width / 3,
                    height: 40
                )
                .foregroundColor(.white)
                .background(.black)
                .cornerRadius(20)
        }
        .padding(.top, 15)
        // 베젤이 없는 아이폰(iPhone 14 등)은 하단 간격 10으로 설정
        // 베젤이 있는 아이폰(iPhone SE 등)은 하단 간격 30으로 설정
        .padding(.bottom, safeAreaInsets.bottom == 0 ? 30 : 10)
    }
    
    var noResultLabel: some View {
        VStack {
            VStack {
                Text("결과 없음")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxHeight: .infinity)
                
                Text("새로운 검색을 시도하십시오.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(height: 50)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - PREVIEW

struct SearchSheetScrollView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSheetScrollView(
            searchQuery: .constant(""),
            searchIndex: .constant(1),
            selectedListMode: .constant(.list),
            selectedCategory: .constant(.all)
        )
        .environmentObject(AladinAPIManager())
    }
}
