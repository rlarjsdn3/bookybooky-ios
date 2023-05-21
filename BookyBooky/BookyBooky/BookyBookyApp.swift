//
//  BookyBookyApp.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/03/13.
//

import SwiftUI

@main
struct BookyBookyApp: App {
    
    // MARK: - WRAPPER PROPERTIES
    
    @StateObject var realmManager = RealmManager()
    @StateObject var aladinAPIManager = AladinAPIManager()
    
    // MARK: - BODY
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    for type in BookListTabTypes.allCases {
                        aladinAPIManager.requestBookListAPI(of: type)
                    }
                }
                .environmentObject(realmManager)
                .environmentObject(aladinAPIManager)
        }
    }
}
