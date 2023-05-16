//
//  TargetBookCellView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/04/27.
//

import SwiftUI
import RealmSwift

enum ReadingBookCellButtonType {
    case home
    case shelf
}

struct ReadingBookCellButton: View {
    
    var readingBook: ReadingBook
    let cellType: ReadingBookCellButtonType
    
    @State private var isPresentingReadingBookView = false
    
    // MARK: - COMPUTED PROPERTIES
    
    var readingBookProgressRate: Double {
        if let readingRecord = readingBook.readingRecords.last {
            return (Double(readingRecord.totalPagesRead) / Double(readingBook.itemPage)) * 100.0
        } else {
            return 0
        }
    }
    
    var readingBookProgressPage: Int {
        if let readingRecord = readingBook.readingRecords.last {
            return readingRecord.totalPagesRead
        } else {
            return 0
        }
    }
    
    var isAscendingTargetDate: Bool {
        let result = Date.now.compare(readingBook.targetDate)
        
        switch result {
        case .orderedAscending, .orderedSame:
            return true
        case .orderedDescending:
            return false
        }
    }
    
    let roundedRectangle = RoundedRectangle(cornerRadius: 15)
    
    // MARK: - BODY
    
    var body: some View {
        NavigationLink {
            ReadingBookView(readingBook: readingBook)
        } label: {
            VStack {
                ZStack {
                    asyncImage(readingBook.cover, width: 150, height: 200, coverShape: roundedRectangle)
                    
                    if !isAscendingTargetDate {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color.red)
                            .frame(width: 150, height: 200)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                            )
                    }
                }
                
                if cellType == .home {
                    progressBar
                }
                
                targetBookTitle
                
                targetBookAuthor
            }
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
    }
}

extension ReadingBookCellButton {
    func asyncImage(url: String) -> some View {
        AsyncImage(url: URL(string: url),
                   transaction: Transaction(animation: .default)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 200)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 15,
                            style: .continuous
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: -5, y: 5)
            case .failure(_), .empty:
                loadingImage
            @unknown default:
                loadingImage
            }
        }
    }
    
    var loadingImage: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.gray.opacity(0.2))
            .frame(width: 150, height: 200)
            .shimmering()
    }
    
    var progressBar: some View {
        HStack {
            ProgressView(value: readingBookProgressRate, total: 100.0)
                .tint(Color.black.gradient)
                .frame(width: 100, alignment: .leading)
            
            Text("\(readingBookProgressRate.formatted(.number.precision(.fractionLength(0))))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    var targetBookTitle: some View {
        Text("\(readingBook.title)")
            .font(.headline)
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: 150, height: 25)
            .padding(.horizontal)
            .padding([cellType == .home ? .top : [], .bottom], -5)
    }
    
    var targetBookAuthor: some View {
        Text("\(readingBook.author)")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)
    }
}

struct ReadingBookCellButton_Previews: PreviewProvider {
    static var previews: some View {
        ReadingBookCellButton(readingBook: ReadingBook.preview, cellType: .home)
    }
}