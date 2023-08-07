//
//  TaskViewmodel.swift
//  NotoriousTaskManagement
//
//  Created by Marcos Vinicius Brito on 07/08/23.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {

  @Published var storedTasks: [Task] = []

  @Published var currentWeek: [Date] = []

  @Published var currentDay: Date = .now

  // MARK: - Filtering Current Day Tasks
  @Published var filteredTasks: [Task]?

  init() {
    generateRandomTasks()
    fetchCurrentWeek()
    filterCurrentDayTasks()
  }

  // MARK: - Filter Current Day tasks
  func filterCurrentDayTasks() {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }

      let calendar = Calendar.current
      let filtered = self.storedTasks.filter { task in
        calendar.isDate(task.taskDate, inSameDayAs: self.currentDay)
      }
        .sorted { $0.taskDate < $1.taskDate }

      DispatchQueue.main.async {
        withAnimation {
          self.filteredTasks = filtered
        }
      }
    }
  }

  func extractDate(date: Date, format: String) -> String {
    let formatter = DateFormatter()

    formatter.dateFormat = format

    return formatter.string(from: date)
  }

  func isTodayDay(_ date: Date) -> Bool {
    let calendar = Calendar.current

    return calendar.isDateInToday(date)
  }

  func isCurrentDay(_ date: Date) -> Bool {
    let calendar = Calendar.current

    return calendar.isDate(date, inSameDayAs: currentDay)
  }

  func isCurrentHour(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let currentHour = calendar.component(.hour, from: .now)

    return hour == currentHour
  }

  private func generateRandomTasks() {
    let taskTitles = ["Buy groceries", "Clean the house", "Finish the project", "Call a friend", "Go for a run"]
    let taskDescriptions = ["Remember to buy milk and bread.", "Clean the living room.", "Work on the presentation.", "Catch up with John.", "Run 5 miles."]

    var storedTasks: [Task] = []
    for _ in 1...10 {
      let randomTitle = taskTitles.randomElement() ?? ""
      let randomDescription = taskDescriptions.randomElement() ?? ""
      let randomDate = generateDateUntilEndOfWeek()

      let newTask = Task(taskTitle: randomTitle, taskDescription: randomDescription, taskDate: randomDate)
      print(extractDate(date: newTask.taskDate, format: "dd-MM-yy hh:mm:ss"))
      storedTasks.append(newTask)
    }

    self.storedTasks = storedTasks
  }

  private func generateDateUntilEndOfWeek() -> Date {
    let calendar = Calendar.current
    var currentDate = Date()

    // Set the time components of currentDate to the start of the day
    currentDate = calendar.startOfDay(for: currentDate)

    // Get the end of the day (one second before midnight)
    let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: currentDate)!

    // Convert Date instances to TimeIntervals
    let currentTimeInterval = currentDate.timeIntervalSince1970
    let endOfDayTimeInterval = endOfDay.timeIntervalSince1970

    // Generate a random time interval within the same day
    let randomTimeInterval = TimeInterval.random(in: currentTimeInterval...endOfDayTimeInterval)

    // Create a new date using the random time interval
    let randomDate = Date(timeIntervalSince1970: randomTimeInterval)

    return randomDate
  }

  private func fetchCurrentWeek() {
    let currentDay = Date()
    let calendar = Calendar.current

    let week = calendar.dateInterval(of: .weekOfMonth, for: currentDay)

    guard let firstWeekDay = week?.start else { return }

    (1...7).forEach { day in
      if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
        currentWeek.append(weekday)
      }
    }
  }
}
