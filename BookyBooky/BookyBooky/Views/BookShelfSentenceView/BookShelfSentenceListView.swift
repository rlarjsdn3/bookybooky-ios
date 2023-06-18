//
//  BookShelfSentenceListView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/06/03.
//

import SwiftUI
import RealmSwift

struct BookShelfSentenceListView: View {
    
    // MARK: - WRAPPER PROPERTIES
    
    @ObservedResults(CompleteBook.self) var readingBooks
    
    @Binding var searchQuery: String
    @Binding var selectedSortType: SentenceSortCriteria
    @Binding var selectedFilter: [String]
    
    // 계산 프로퍼티 리팩토링 - Results Extension에 집어넣기
    
    var sortedCollectSentence: [CompleteBook] {
        var sorted: [CompleteBook] = []
        
        switch selectedSortType {
        case .titleAscending:
            sorted = readingBooks.sorted { $0.title < $1.title }
        case .titleDescending:
            sorted = readingBooks.sorted { $0.title > $1.title }
        }
        
        if selectedFilter.isEmpty {
            return sorted
        } else {
            return sorted.filter({ $0.title.contains(contentsOf: selectedFilter) })
        }
        // 도서 필터링 코드 추가 (전체 혹은 선택한 도서들)
    }
    
    var filteredCollectSentence: [CompleteBook] {
        var filtered: [CompleteBook]
        
        if searchQuery.isEmpty {
            return sortedCollectSentence
        } else {
            filtered = sortedCollectSentence.filter({
                $0.title.contains(searchQuery) || $0.author.contains(searchQuery)
            })
            return filtered
        }
    }
    
    // MARK: - BODY
    
    var body: some View {
        Group {
            let filteredSentece = filteredCollectSentence
            
            if filteredSentece.isEmpty {
                VStack(spacing: 5) {
                    Spacer()
                    
                    Text("수집한 문장이 없음")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("문장을 수집해보세요.")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(filteredCollectSentence) { readingBook in
                            if !readingBook.collectSentences.isEmpty {
                                Section {
                                    VStack {
                                        ForEach(readingBook.collectSentences.sorted { $0.page < $1.page }, id: \.self) { collect in
                                            SentenceButton(readingBook, collectSentence: collect)
                                        }
                                    }
                                } header: {
                                    Text(readingBook.title)
                                        .font(.title3.weight(.bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .padding([.horizontal, .top, .bottom])
                                        .background(Color.white)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - PREVIEW

struct BookShelfSentenceListView_Previews: PreviewProvider {
    static var previews: some View {
        BookShelfSentenceListView(
            searchQuery: .constant(""),
            selectedSortType: .constant(.titleAscending),
            selectedFilter: .constant([""])
        )
    }
}
