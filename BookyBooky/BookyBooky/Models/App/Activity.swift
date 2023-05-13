//
//  Activity.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/05/12.
//

import Foundation

struct Activity: Hashable {
    var date: Date
    var title: String
    var author: String
    var category: Category
    var itemPage: Int
    var isbn13: String
    
    var numOfPagesRead: Int
    var totalPagesRead: Int
}

extension Activity {
    static var preview: Activity {
        Activity(date: Date.now, title: "Java의 정석", author: "남궁성", category: Category.computer, itemPage: 300, isbn13: "123456789012", numOfPagesRead: 3, totalPagesRead: 3)
    }
}