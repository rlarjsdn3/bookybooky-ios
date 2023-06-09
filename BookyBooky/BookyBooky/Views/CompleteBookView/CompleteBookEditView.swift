//
//  EditBookInformationView.swift
//  BookyBooky
//
//  Created by 김건우 on 2023/05/10.
//

import SwiftUI
import RealmSwift

struct CompleteBookEditView: View {
    
    // MARK: - WRAPPER PROPERTIES
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var realmManager: RealmManager
    
    @State private var inputTitle = ""
    @State private var inputPublisher = ""
    @State private var inputCategory: Category = .all
    @State private var inputTargetDate = Date.now
    @State private var isPresentingKeyboard = false
    
    // MARK: - PROPERTIES
    
    let completeBook: CompleteBook
    
    // MARK: - INTIALIZER
    
    init(_ completeBook: CompleteBook) {
        self.completeBook = completeBook
    }
    
    // MARK: - BODY
    
    var body: some View {
        editBookContent
            .onAppear {
                inputTitle = completeBook.title
                inputPublisher = completeBook.publisher
                inputCategory = completeBook.category
                inputTargetDate = completeBook.targetDate
            }
    }
}

// MARK: - EXTENSIONS

extension CompleteBookEditView {
    var editBookContent: some View {
        NavigationStack {
            VStack {
                inputFieldGroup
                
                editButton
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("도서 정보 수정하기")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationCornerRadius(30)
    }
    
    var inputFieldGroup: some View {
        VStack {
            titleTextField
            
            publisherTextField
            
            categoryField
            
            if !completeBook.isComplete {
                targetDateField
            }
            
            Spacer()
        }
        .padding()
    }
    
    var titleTextField: some View {
        HStack {
            Text("제목")
                .font(.title3.weight(.bold))
                .padding(.trailing, 50)
            TextField("", text: $inputTitle)
        }
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(Color(.background), in: .rect(cornerRadius: 10))
    }
    
    var publisherTextField: some View {
        HStack {
            Text("출판사")
                .font(.title3.weight(.bold))
                .padding(.trailing, 34)
            TextField("", text: $inputPublisher)
        }
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(Color(.background), in: .rect(cornerRadius: 10))
    }
    
    var categoryField: some View {
        HStack {
            Text("카테고리")
                .font(.title3.weight(.bold))
                .padding(.trailing)
            
            Spacer()
            
            Picker("Category Picker", selection: $inputCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.name)
                        .tag(category.name)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
        .background(Color(.background), in: .rect(cornerRadius: 10))
    }
    
    var targetDateField: some View {
        HStack {
            Text("목표일자")
                .font(.title3.weight(.bold))
                .padding(.trailing)
            
            Spacer()
            
            DatePicker(
                    "DatePicker",
                    selection: $inputTargetDate,
                    in: Date(timeIntervalSinceNow: 86400)...(Calendar.current.date(byAdding: .day, value: 365, to: Date())!),
                    displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(completeBook.category.themeColor)
                .padding(.horizontal, 3)
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
        .background(Color(.background), in: .rect(cornerRadius: 10))
    }
    
    var editButton: some View {
        Button {
            realmManager.editReadingBook(
                completeBook,
                title: inputTitle,
                publisher: inputPublisher,
                category: inputCategory,
                targetDate: inputTargetDate
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        } label: {
            Text("수정하기")
        }
        .onReceive(keyboardPublisher) { value in
            withAnimation {
                isPresentingKeyboard = value
            }
        }
        .buttonStyle(BottomButtonStyle(backgroundColor: Color.black))
        .padding(.bottom, isPresentingKeyboard ? 20 : 0)
    }
}

// MARK: - PREVIEW

struct EditBookInformationView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteBookEditView(CompleteBook.preview)
            .environmentObject(RealmManager())
    }
}
