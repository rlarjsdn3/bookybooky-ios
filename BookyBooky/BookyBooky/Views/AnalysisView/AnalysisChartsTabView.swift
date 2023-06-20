//
//  AnalysisChartsTabView.swift
//  BookyBooky
//
//  Created by 김건우 on 6/14/23.
//

import SwiftUI
import Charts
import RealmSwift

struct AnalysisChartsTabView: View {
    
    // MARK: - WRAPPER PROPERTIES
    
    @ObservedResults(CompleteBook.self) var readingBooks
    
    // MARK: - COMPUTED PROPERTIES
    
    var totalPagesByCategoryChartData: [TotalPagesReadByCategory] {
        var totalPagesReadByCategory: [TotalPagesReadByCategory] = []
        
        for readingBook in readingBooks {
            if let index = totalPagesReadByCategory.firstIndex(where: { $0.category == readingBook.category }) {
                totalPagesReadByCategory[index].pages += readingBook.lastRecord?.totalPagesRead ?? 0
            } else {
                if let last = readingBook.lastRecord {
                    totalPagesReadByCategory.append(
                        .init(category: readingBook.category, pages: last.totalPagesRead)
                    )
                }
            }
        }
        
        return totalPagesReadByCategory.sorted { $0.pages > $1.pages }
    }
    
    var totalDailyReadPagesChartData: [DailyPagesRead] {
        var dailyPages: [DailyPagesRead] = []
        
        for readingBook in readingBooks {
            for record in readingBook.readingRecords {
                if let index = dailyPages.firstIndex(where: { $0.date.isEqual([.year, .month, .day], date: record.date) }) {
                    dailyPages[index].pages += record.numOfPagesRead
                } else {
                    dailyPages.append(
                        DailyPagesRead(date: record.date, pages: record.numOfPagesRead)
                    )
                }
            }
        }
        
        return dailyPages
    }
    
    var monthlyBooksCompletedChartData: [MonthlyCompleteBook] {
        var monthlyCompleteBook: [MonthlyCompleteBook] = []
        
        for readingBook in readingBooks {
            if readingBook.isComplete {
                if let index = monthlyCompleteBook.firstIndex(where: { $0.date.isEqual([.year ,.month], date: readingBook.completeDate ?? Date()) } ) {
                    monthlyCompleteBook[index].count += 1
                } else {
                    monthlyCompleteBook.append(
                        MonthlyCompleteBook(date: readingBook.completeDate ?? Date(), count: 1)
                    )
                }
            }
        }
        return monthlyCompleteBook
    }
    
    // MARK: - BODY
    
    var body: some View {
        VStack {
            summaryHeaderText
            
            totalPagesReadByCategoryChartCellButton
            
            totalDailyPagesReadChartCellButton
            
            // NOTE: - 해당 기능은 버전 1.1에 언락될 예정입니다.
            // totalNumberOfBooksReadPerMonthChartCellButton
        }
    }
}

// MARK: - EXTENSIONS

extension AnalysisChartsTabView {
    var summaryHeaderText: some View {
        Text("요약")
            .font(.title2.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, -2)
    }
    
    var totalPagesReadByCategoryChartCellButton: some View {
        NavigationLink {
            TotalPagesCountByCategoryChartView(chartData: totalPagesByCategoryChartData)
        } label: {
            VStack {
                chartTitleLabel("분야 별 총 읽은 페이지")
                
                if totalPagesByCategoryChartData.isEmpty {
                    unableToDisplayChartLabel
                } else {
                    Chart(totalPagesByCategoryChartData, id: \.self) { element in
                        BarMark(
                            x: .value("pages", element.pages),
                            stacking: .normalized
                        )
                        .foregroundStyle(by: .value("category", element.category.name))
                    }
                    .frame(height: 50)
                    .padding(5)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 10))
        }
        .disabled(totalPagesByCategoryChartData.isEmpty ? true : false)
        .buttonStyle(.plain)
    }
    
    var totalDailyPagesReadChartCellButton: some View {
        NavigationLink {
            DailyPagesReadChartView(dailyChartData: totalDailyReadPagesChartData)
        } label: {
            VStack {
                chartTitleLabel("일일 독서 페이지")
                
                if totalPagesByCategoryChartData.isEmpty {
                    unableToDisplayChartLabel
                } else {
                    Chart(totalDailyReadPagesChartData, id: \.self) { element in
                        BarMark(
                            x: .value("date", element.date, unit: .day),
                            y: .value("pages", element.pages)
                        )
                        .cornerRadius(5.0)
                        .foregroundStyle(element.date.isEqual([.year, .month, .day], date: Date()) ? Color.orange : Color.gray)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(
                        domain: Date().addingTimeInterval(-14*86400)...Date(),
                        range: .plotDimension(startPadding: 10, endPadding: 10)
                    )
                    .frame(height: 50)
                    .padding(5)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .background(Color.white, in: .rect(cornerRadius: 10))
        }
        .disabled(totalPagesByCategoryChartData.isEmpty ? true : false)
        .buttonStyle(.plain)
    }
    
    var totalNumberOfBooksReadPerMonthChartCellButton: some View {
        NavigationLink {
            MonthlyBooksCompletedChartView(chartData: monthlyBooksCompletedChartData)
        } label: {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Label("월 별 읽은 도서 수", systemImage: "book")
                        .font(.headline)
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    Group {
                        Text("자세히 보기")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                }
                
                if monthlyBooksCompletedChartData.isEmpty {
                    unableToDisplayChartLabel
                } else {
                    Chart(monthlyBooksCompletedChartData, id: \.self) { element in
                        BarMark(
                            x: .value("date", element.date, unit: .month),
                            y: .value("pages", element.count)
                        )
                        .cornerRadius(5.0)
                        .foregroundStyle(element.date.isEqual([.year, .month], date: Date()) ? Color.blue : Color.gray)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(
                        domain: Date().addingTimeInterval(-30*86400*12)...Date(),
                        range: .plotDimension(startPadding: 10, endPadding: 10)
                    )
                    .frame(height: 50)
                    .padding(5)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .background(Color.white, in: .rect(cornerRadius: 10))
        }
        .disabled(monthlyBooksCompletedChartData.isEmpty ? true : false)
        .buttonStyle(.plain)
    }
    
    var unableToDisplayChartLabel: some View {
        VStack(spacing: 3) {
            Text("차트를 표시할 수 없음")
                .font(.headline)
            
            Text("독서를 시작해보세요.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding()
    }
    
    func chartTitleLabel(_ title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Label(title, systemImage: "book")
                .font(.headline)
                .foregroundStyle(Color.black)
            
            Spacer()
            
            Group {
                Text("자세히 보기")
                Image(systemName: "chevron.right")
            }
            .font(.subheadline)
            .foregroundStyle(Color.secondary)
        }
    }
}

// MARK: - PREVIEW

#Preview {
    AnalysisChartsTabView()
}