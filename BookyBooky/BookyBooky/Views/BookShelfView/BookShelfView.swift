//
//  BookShelfView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/04/07.
//

import SwiftUI
import RealmSwift

struct BookShelfView: View {
    @ObservedResults(FavoriteBook.self) var favoriteBooks
    
    @State private var scrollYOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            BookShelfHeaderView(scrollYOffset: $scrollYOffset)
            
            BookShelfScrollView(scrollYOffset: $scrollYOffset)
            
            Spacer()
        }
    }
}

struct BookShelfView_Previews: PreviewProvider {
    static var previews: some View {
        BookShelfView()
    }
}
