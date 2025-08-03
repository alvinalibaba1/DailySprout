//
//  ContentView.swift
//  DailySprout
//
//  Created by Alvin Reyvaldo on 02/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = DailySproutStore()
    @State private var newGoalText = ""
    @State private var showingAddGoal = false
    @State private var showStreakCelebration = false
    @State private var celebrationMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color.green.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with enhanced design
                        VStack(spacing: 12) {
                            // Main sprout with subtle shadow
                            Text("🌱")
                                .font(.system(size: 80))
                                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("DailySprout")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            if store.streakData.currentStreak > 0 {
                                HStack {
                                    Text("🔥")
                                        .font(.title2)
                                    Text("\(store.streakData.currentStreak) day streak!")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .scaleEffect(store.hasCompletedToday ? 1.05 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: store.streakData.currentStreak)
                            }
                        }
                        .padding(.top, 20)
                
                        // Today's Goals Section
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Goals")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Small steps, big impact")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { showingAddGoal = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Add Goal")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                            }
                            
                            if store.todaysGoals.isEmpty {
                                VStack(spacing: 16) {
                                    Text("🌿")
                                        .font(.system(size: 50))
                                    Text("Ready to grow?")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("Add your first micro-goal and start your sprouting journey!")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(store.todaysGoals.enumerated()), id: \.element.id) { index, goal in
                                        GoalRowView(goal: goal) {
                                            let oldStreak = store.streakData.currentStreak
                                            store.toggleGoal(at: index)
                                            
                                            // Show celebration if streak increased
                                            if store.streakData.currentStreak > oldStreak {
                                                showStreakCelebration(for: store.streakData.currentStreak)
                                            }
                                        } onDelete: {
                                            store.removeGoal(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                
                        // Progress Overview
                        NavigationLink(destination: ProgressView(store: store)) {
                            HStack(spacing: 16) {
                                VStack {
                                    Text("📊")
                                        .font(.system(size: 28))
                                }
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Progress")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("\(store.streakData.totalWins) total wins")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(store: store, isPresented: $showingAddGoal)
        }
        .alert("🎉 Streak Achievement!", isPresented: $showStreakCelebration) {
            Button("Keep Growing! 🌱") { }
        } message: {
            Text(celebrationMessage)
        }
    }
    
    private func showStreakCelebration(for streak: Int) {
        switch streak {
        case 1:
            celebrationMessage = "You sprouted today! Your journey begins! 🌱"
        case 3:
            celebrationMessage = "3 days strong! You're building momentum! 💪"
        case 7:
            celebrationMessage = "One week streak! You're forming a habit! 🔥"
        case 14:
            celebrationMessage = "Two weeks! Your consistency is impressive! ⭐"
        case 30:
            celebrationMessage = "30 days! You're a habit master! 👑"
        case let x where x % 10 == 0:
            celebrationMessage = "\(streak) days! Your dedication is inspiring! 🚀"
        default:
            celebrationMessage = "Day \(streak)! Keep up the amazing work! 🌟"
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showStreakCelebration = true
        }
    }
}

struct GoalRowView: View {
    let goal: DailyGoal
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(goal.isCompleted ? 
                              LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color(.systemGray5), Color(.systemGray6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(goal.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(goal.isCompleted ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: goal.isCompleted)
            }
            
            // Goal text with better typography
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.text)
                    .font(.system(size: 16, weight: .medium))
                    .strikethrough(goal.isCompleted)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
                    .animation(.easeInOut(duration: 0.2), value: goal.isCompleted)
                
                if goal.isCompleted {
                    Text("Completed! 🌱")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                if goal.isCompleted {
                    Text("🌱")
                        .font(.system(size: 20))
                        .scaleEffect(1.2)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: goal.isCompleted)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    goal.isCompleted ?
                    LinearGradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            goal.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: goal.isCompleted ? .green.opacity(0.1) : .black.opacity(0.03),
                    radius: goal.isCompleted ? 6 : 4,
                    x: 0,
                    y: 2
                )
        )
        .animation(.easeInOut(duration: 0.3), value: goal.isCompleted)
    }
}

struct AddGoalView: View {
    @ObservedObject var store: DailySproutStore
    @Binding var isPresented: Bool
    @State private var goalText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color.green.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("🌿")
                            .font(.system(size: 60))
                            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("Add a Micro-Goal")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Small steps lead to big changes!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("What's your micro-goal for today?", text: $goalText)
                                .font(.body)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(goalText.isEmpty ? Color.gray.opacity(0.3) : Color.green.opacity(0.5), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            
                            Text("Examples: Drink 1 glass of water, Send that email, Take a 5-minute walk")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                isPresented = false
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(.systemGray6))
                            )
                            
                            Button("Add Goal") {
                                if !goalText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    store.addGoal(goalText.trimmingCharacters(in: .whitespaces))
                                    isPresented = false
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        goalText.trimmingCharacters(in: .whitespaces).isEmpty ?
                                        LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            )
                            .shadow(color: goalText.trimmingCharacters(in: .whitespaces).isEmpty ? .clear : .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            .disabled(goalText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProgressView: View {
    @ObservedObject var store: DailySproutStore
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            // Same gradient background as home screen
            LinearGradient(
                colors: [Color(.systemBackground), Color.green.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with sprout logo restored
                    VStack(spacing: 12) {
                        Text("🌱")
                            .font(.system(size: 80))
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        HStack {
                            Text("Your Progress")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Spacer()
                            
                            Button(action: { createAndShareProgress() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Share")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        Text("Every small step counts!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stats section with consistent styling
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Stats")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Track your growth journey")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            ProgressCard(
                                title: "Current Streak",
                                value: "\(store.streakData.currentStreak)",
                                subtitle: "days in a row",
                                color: .orange,
                                icon: "🔥"
                            )
                            
                            ProgressCard(
                                title: "Longest Streak",
                                value: "\(store.streakData.longestStreak)",
                                subtitle: "your best run",
                                color: .purple,
                                icon: "🏆"
                            )
                            
                            ProgressCard(
                                title: "Total Wins",
                                value: "\(store.streakData.totalWins)",
                                subtitle: "goals completed",
                                color: .green,
                                icon: "🌟"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Achievement section matching home screen empty state style
                    if store.streakData.currentStreak >= 7 {
                        VStack(spacing: 16) {
                            Text("🎉")
                                .font(.system(size: 50))
                            Text("Habit Master!")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("You're building amazing consistency. Keep sprouting!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    } else if store.streakData.totalWins > 0 {
                        VStack(spacing: 16) {
                            Text("🌿")
                                .font(.system(size: 50))
                            Text("Keep Growing!")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("You're making progress. Every small win counts!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(activityItems: [shareImage])
            }
        }
    }
    
    private func createAndShareProgress() {
        let renderer = ImageRenderer(content: ShareableProgressCard(store: store))
        renderer.scale = 3.0 // High resolution for sharing
        
        DispatchQueue.main.async {
            if let image = renderer.uiImage {
                self.shareImage = image
                self.showingShareSheet = true
            }
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon section matching home screen style
            VStack {
                Text(icon)
                    .font(.system(size: 28))
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(LinearGradient(
                        colors: [color.opacity(0.2), color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            
            // Content section
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct ShareableProgressCard: View {
    @ObservedObject var store: DailySproutStore
    
    var motivationalMessage: String {
        if store.streakData.currentStreak >= 30 {
            return "Habit Master! 🏆"
        } else if store.streakData.currentStreak >= 14 {
            return "Consistency Champion! ⭐"
        } else if store.streakData.currentStreak >= 7 {
            return "Week Strong! 💪"
        } else if store.streakData.totalWins >= 10 {
            return "Making Progress! 🚀"
        } else {
            return "Growing Every Day! 🌱"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Beautiful gradient background
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("🌱")
                        .font(.system(size: 60))
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text("DailySprout")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(motivationalMessage)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Stats in a beautiful layout
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("\(store.streakData.currentStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Current\nStreak")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 60)
                    
                    VStack(spacing: 8) {
                        Text("\(store.streakData.longestStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Best\nStreak")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 60)
                    
                    VStack(spacing: 8) {
                        Text("\(store.streakData.totalWins)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Total\nWins")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                
                // Inspiring quote
                VStack(spacing: 8) {
                    Text("\"Small steps every day lead to big changes over time\"")
                        .font(.body)
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    Text("Join me on DailySprout! 🌿")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 40)
            .background(
                LinearGradient(
                    colors: [
                        Color.green,
                        Color.green.opacity(0.8),
                        Color.blue.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .frame(width: 400, height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
