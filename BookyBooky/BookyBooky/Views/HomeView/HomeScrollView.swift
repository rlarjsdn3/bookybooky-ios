//
//  HomeScrollView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/04/20.
//

import SwiftUI
import SwiftDate
import RealmSwift

struct HomeScrollView: View {
    
    let COVER_HEGHT_RATIO = 0.18        // 화면 사이즈 대비 표지(커버) 이미지 높이 비율
    let BACKGROUND_HEIGHT_RATIO = 0.3   // 화면 사이즈 대비 바탕 색상 높이 비율
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @ObservedResults(CompleteTargetBook.self) var completeTargetBooks
    
    // 애니메이션 / 애니메이션 없는 변수 구분하기
    @State private var selectedCategory: Category = .all
    @State private var selectedAnimation: Category = .all
    
    @State private var selectedSort: BookSort = .latestOrder
    
    @State private var isLoading = true
    
    @State private var startOffset = 0.0
    @Binding var scrollYOffset: Double
    
    @Namespace var underlineAnimation
    
    var categories: [Category] {
        var categories: [Category] = [.all]
        
        for book in completeTargetBooks where !categories.contains(book.category) {
            categories.append(book.category)
        }
        
        return categories
    }
    
    var filteredCompleteTargetBooks: [CompleteTargetBook] {
        var filteredBooks: [CompleteTargetBook] = []
        
        // 애니메이션이 없는 변수로 코드 수정하기
        if selectedCategory == .all {
            return Array(completeTargetBooks)
        } else {
            for book in completeTargetBooks where selectedCategory == book.category {
                filteredBooks.append(book)
            }
            
            return filteredBooks
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    VStack(alignment: .leading) {
                        Text(Date().toFormat("M월 dd일 EEEE", locale: Locale(identifier: "ko")))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .opacity(scrollYOffset > 10 ? 0 : 1)
                        
                        Text("홈")
                            .font(.system(size: 34 + getFontSizeOffset()))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.001)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    
                    Text("활동")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    
                    ScrollView {
                        Text("UI 미완성")
                            .font(.title3)
                            .padding()
                            .background(.gray.opacity(0.3))
                            .cornerRadius(15)
                            .shimmering()
                            .padding(.vertical, 25)
                    }
                    
                    HStack {
                        Text("독서")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        
                        Menu {
                            Section {
                                sortButtons
                            } header: {
                                Text("도서 정렬")
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        .navigationBarItemStyle()
                    }
                    .padding(.bottom, -10)
                    
                    
                    Section {
                        if completeTargetBooks.isEmpty {
                            VStack(spacing: 5) {
                                Text("읽고 있는 도서가 없어요 :)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("우측 상단 버튼을 클릭해 독서를 시작해보세요!")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 50)
                        } else {
                            LazyVGrid(columns: columns, spacing: 25) {
                                ForEach(filteredCompleteTargetBooks) { book in
                                    TargetBookCellView(targetBook: book, selectedCategory: $selectedCategory)
                                }
                                
//                                if filteredCompleteTargetBooks.count <= 2 {
//                                    ForEach(0..<2) { _ in
//                                        Rectangle()
//                                            .fill(.gray)
//                                            .frame(width: 150, height: 265)
//                                    }
//                                }
                            }
                            .padding([.horizontal, .top])
                            .padding(.bottom, 30)
                            .id("Scroll_To_Top")
                        }
                    } header: {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(categories, id: \.self) { category in
                                        HomeCategoryButtonsView(category: category, selectedCategory: $selectedCategory, selectedAnimation: $selectedAnimation, scrollProxy: scrollProxy, underlineAnimation: underlineAnimation)
                                            .id("\(category.rawValue)")
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding([.horizontal, .bottom], 5)
                            }
                            .id("Scroll_To_Category")
                        }
                        .background(.white)
                        .overlay(alignment: .bottom) {
                            Divider()
                                .opacity(scrollYOffset > 30 ? 1 : 0)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            let offset = proxy.frame(in: .global).minY
                            if startOffset == 0 {
                                self.startOffset = offset
                            }
                            withAnimation(.easeInOut(duration: 0.1)) {
                                scrollYOffset = startOffset - offset
                            }
                            
                            print(scrollYOffset)
                        }
                        return Color.clear
                    }
                    .frame(width: 0, height: 0)
                }
            }
        }
    }
    
    /// 스크롤의 최상단 Y축 좌표의 위치에 따라 폰트의 추가 사이즈를 반환하는 함수입니다.
    func getFontSizeOffset() -> CGFloat {
        let START_yOFFSET = 20.0 // 폰트 크기가 커지기 시작하는 Y축 좌표값
        let END_yOFFSET = 130.0  // 폰트 크기가 최대로 커진 Y축 좌표값
        let SCALE = 0.03         // Y축 좌표값에 비례하여 커지는 폰트 크기의 배수
        
        // Y축 좌표가 START_yOFFSET 이상이라면
        if -scrollYOffset > START_yOFFSET {
            // Y축 좌표가 END_yOFFSET 미만이라면
            if -scrollYOffset < END_yOFFSET {
                return -scrollYOffset * SCALE // 현재 최상단 Y축 좌표의 SCALE배만큼 추가 사이즈 반환
            // Y축 좌표가 END_yOFFSET 이상이면
            } else {
                return END_yOFFSET * SCALE // 폰트의 최고 추가 사이즈 반환
            }
        }
        // Y축 좌표가 START_yOFFSET 미만이라면
        return 0.0 // 폰트 추가 사이즈 없음
    }
}

extension HomeScrollView {
    var sortButtons: some View {
        ForEach(BookSort.allCases, id: \.self) { sort in
            Button {
                // 버튼을 클릭하면
                withAnimation(.spring()) {
                    // 곧바로 스크롤을 제일 위로 올리고
//                    scrollProxy.scrollTo("Scroll_To_Top", anchor: .top)
                    // 0.3초 대기 후, 정렬 애니메이션 수행
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            selectedSort = sort
                        }
                        Haptics.shared.play(.rigid)
                    }
                }
            } label: {
                HStack {
                    Text(sort.rawValue)
                    
                    // 현재 선택한 정렬 타입에 체크마크 표시
                    if selectedSort == sort {
                        checkmark
                    }
                }
            }
        }
    }
    
    var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.title3)
    }
}

struct HomeScrollView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScrollView(scrollYOffset: .constant(0.0))
    }
}
