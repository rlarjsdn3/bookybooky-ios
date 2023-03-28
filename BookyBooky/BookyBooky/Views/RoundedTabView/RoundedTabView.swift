//
//  RoundedTabView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/03/27.
//

import SwiftUI

struct RoundedTabView: View {
    @Binding var selected: TabItem
    @Namespace var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { item in
                TabButtonView(selected: $selected, item: item, namespace: namespace)
            }
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray, lineWidth: 0.2)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .frame(height: 100)
            }
            .offset(y: 16)
        }
        // 베젤이 없는 아이폰(iPhone 14 등)은 하단 간격 0으로 설정
        // 베젤이 있는 아이폰(iPhone SE 등)은 하단 간격 20으로 설정
        .padding(.bottom, safeAreaInsets.bottom != 0 ? 0 : 20)
    }
}

struct RoundedTabView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTabView(selected: .constant(.home))
    }
}
