import Foundation
import SwiftUI

struct DailyGoal: Identifiable, Codable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
    var dateCreated: Date = Date()
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateCreated)
    }
}

struct StreakData: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalWins: Int = 0
    var lastCompletionDate: Date?
    
    mutating func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastCompletionDate {
            let lastCompletionDay = Calendar.current.startOfDay(for: lastDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        totalWins += 1
        lastCompletionDate = Date()
    }
    
    func canIncrementToday() -> Bool {
        guard let lastDate = lastCompletionDate else { return true }
        let today = Calendar.current.startOfDay(for: Date())
        let lastCompletionDay = Calendar.current.startOfDay(for: lastDate)
        return !Calendar.current.isDate(lastCompletionDay, inSameDayAs: today)
    }
}

class DailySproutStore: ObservableObject {
    @Published var todaysGoals: [DailyGoal] = []
    @Published var streakData = StreakData()
    @Published var hasCompletedToday = false
    
    private let goalsKey = "TodaysGoals"
    private let streakKey = "StreakData"
    private let completionKey = "HasCompletedToday"
    
    init() {
        loadData()
        checkNewDay()
    }
    
    private func loadData() {
        if let goalsData = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([DailyGoal].self, from: goalsData) {
            todaysGoals = decodedGoals
        }
        
        if let streakDataSaved = UserDefaults.standard.data(forKey: streakKey),
           let decodedStreak = try? JSONDecoder().decode(StreakData.self, from: streakDataSaved) {
            streakData = decodedStreak
        }
        
        hasCompletedToday = UserDefaults.standard.bool(forKey: completionKey)
    }
    
    private func saveData() {
        if let goalsData = try? JSONEncoder().encode(todaysGoals) {
            UserDefaults.standard.set(goalsData, forKey: goalsKey)
        }
        
        if let streakDataEncoded = try? JSONEncoder().encode(streakData) {
            UserDefaults.standard.set(streakDataEncoded, forKey: streakKey)
        }
        
        UserDefaults.standard.set(hasCompletedToday, forKey: completionKey)
    }
    
    private func checkNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDate = UserDefaults.standard.object(forKey: "LastOpenDate") as? Date ?? Date()
        let lastOpenDay = Calendar.current.startOfDay(for: savedDate)
        
        if !Calendar.current.isDate(today, inSameDayAs: lastOpenDay) {
            todaysGoals.removeAll()
            hasCompletedToday = false
            UserDefaults.standard.set(Date(), forKey: "LastOpenDate")
            saveData()
        }
    }
    
    func addGoal(_ text: String) {
        let newGoal = DailyGoal(text: text)
        todaysGoals.append(newGoal)
        saveData()
    }
    
    func toggleGoal(at index: Int) {
        guard index < todaysGoals.count else { return }
        let wasCompleted = todaysGoals[index].isCompleted
        todaysGoals[index].isCompleted.toggle()
        
        let hasAnyCompleted = todaysGoals.contains { $0.isCompleted }
        
        // If completing a goal for the first time today
        if !wasCompleted && todaysGoals[index].isCompleted && !hasCompletedToday && streakData.canIncrementToday() {
            streakData.updateStreak()
            hasCompletedToday = true
        }
        // If uncompleting the last completed goal, reset today's completion
        else if wasCompleted && !todaysGoals[index].isCompleted && !hasAnyCompleted {
            hasCompletedToday = false
            // Note: We don't decrement streak here to avoid confusion
        }
        
        saveData()
    }
    
    func removeGoal(at index: Int) {
        guard index < todaysGoals.count else { return }
        todaysGoals.remove(at: index)
        saveData()
    }
}