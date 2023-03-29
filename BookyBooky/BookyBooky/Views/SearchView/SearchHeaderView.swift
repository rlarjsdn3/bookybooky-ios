//
//  SearchHeaderView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/03/29.
//

import SwiftUI

struct SearchHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "square")
                .font(.title)
                .fontWeight(.semibold)
                .hidden()
            
            Spacer()
            
            Text("검색")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
        }
        .padding()
    }
}

struct SearchHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SearchHeaderView()
    }
}