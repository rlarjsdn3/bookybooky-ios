//
//  SentenceCellButton.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/06/01.
//

import SwiftUI

enum SentenceCellButtonType {
    case home
    case shelf
}

struct SentenceCellButton: View {
    
    @EnvironmentObject var realmManager: RealmManager
    
    @State private var isPresentingModifySentenceSheetView = false
    
    let readingBook: ReadingBook
    let collectSentence: CollectSentences
    
    init(_ readingBook: ReadingBook, collectSentence: CollectSentences) {
        self.readingBook = readingBook
        self.collectSentence = collectSentence
    }
    
    var body: some View {
        VStack {
            NavigationLink {
                Text("dw")
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(collectSentence.sentence)
                        .fontWeight(.bold)
                        .lineLimit(5)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding([.leading, .top, .trailing])
            }
            .buttonStyle(.plain)
            
            HStack {
                Text(collectSentence.date.standardDateFormat)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(collectSentence.page)페이지")
                    .padding(.vertical, 3.2)
                    .padding(.horizontal, 15)
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .background(readingBook.category.accentColor)
                    .clipShape(Capsule())
                    .padding(.trailing)
                
                Menu {
                    Button {
                        isPresentingModifySentenceSheetView = true
                    } label: {
                        Label("수정", systemImage: "square.and.pencil")
                    }
                    
                    Button(role: .destructive) {
                        realmManager.deleteSentence(readingBook, id: collectSentence._id)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(readingBook.category.accentColor)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .sheet(isPresented: $isPresentingModifySentenceSheetView) {
            ModifySentenceSheetView(readingBook, collectSentence: collectSentence)
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
    }
}

struct SentenceCellButton_Previews: PreviewProvider {
    static var previews: some View {
        SentenceCellButton(
            ReadingBook.preview,
            collectSentence: CollectSentences.preview
        )
        .environmentObject(RealmManager())
    }
}
