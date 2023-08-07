//
//  Home.swift
//  NotoriousTaskManagement
//
//  Created by Marcos Vinicius Brito on 07/08/23.
//

import SwiftUI

struct Home: View {
  @StateObject var taskViewModel: TaskViewModel = .init()
  @Namespace var animation

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
        Section {
          // MARK: - Current Week View
          ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 12) {

              ForEach(taskViewModel.currentWeek, id: \.self) { day in

                VStack(spacing: 12) {
                  // dd will return day as 01, 02, ... 30, 31
                  Text(taskViewModel.extractDate(date: day, format: "dd"))
                    .font(.headline)
                    .fontWeight(.semibold)

                  // EEE will return day as Mon, Tue, Wed, Thu, Fri, Sat, Sun
                  Text(taskViewModel.extractDate(date: day, format: "EEE"))
                    .font(.headline)
                    .fontWeight(.semibold)

                  Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .opacity(taskViewModel.isCurrentDay(day) ? 1 : 0)
                  
                } //: VStack
                .foregroundStyle(taskViewModel.isCurrentDay(day) ? .primary : .secondary)
                .foregroundColor(taskViewModel.isCurrentDay(day) ? Color.white : Color.black)
                .frame(width: 45, height: 90)
                .background(
                  ZStack {
                    if taskViewModel.isCurrentDay(day) {
                      Capsule()
                        .fill(.black)
                        .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                    }
                  }
                )
                .contentShape(Capsule())
                .onTapGesture {
                  withAnimation {
                    taskViewModel.currentDay = day
                  }
                }
              } //: ForEach
            } //: HStack
            .padding(.horizontal)
          } //: ScrollView

          TaskView()
        } header: {
          HeaderView()
        }
      } //: LazyVStack
    } //: ScrollView
    .ignoresSafeArea(.container, edges: .top)
  }

  // MARK: - Tasks View
  func TaskView() -> some View {
    LazyVStack(spacing: 20) {
      if let tasks = taskViewModel.filteredTasks {
        if tasks.isEmpty {
          Text("No tasks found!!!")
            .font(.subheadline)
            .fontWeight(.light)
            .offset(y: 100)
        }
        else {
          ForEach(tasks) { task in
            TaskCardView(task: task)
          }
        }
      }
      else {
        ProgressView()
          .offset(y: 100)
      }
    } //: LazyVStack
    .padding()
    .padding(.top)
    .onChange(of: taskViewModel.currentDay) { newValue in
      taskViewModel.filterCurrentDayTasks()
    }
  }

  // MARK: - Task Card View
  func TaskCardView(task: Task) -> some View {
    HStack(alignment: .top, spacing: 32) {
      VStack(spacing: 12) {
        Circle()
          .fill(taskViewModel.isCurrentHour(task.taskDate) ? .black : .clear)
          .frame(width: 16, height: 16)
          .background(
            Circle()
              .stroke(.black, lineWidth: 1)
              .padding(-3)
          )
          .scaleEffect(!taskViewModel.isCurrentHour(task.taskDate) ? 0.8 : 1)

        Rectangle()
          .fill(.black)
          .frame(width: 3)
      } //: VStack

      VStack(spacing: 12) {
        HStack(alignment: .top, spacing: 12) {

          VStack(alignment: .leading, spacing: 12) {
            Text(task.taskTitle)
              .font(.title2)
              .fontWeight(.bold)

            Text(task.taskDescription)
              .font(.callout)
              .foregroundColor(.secondary)
          }
          .hLeading()

          Text(task.taskDate.formatted(date: .omitted, time: .shortened))
            .font(.headline)
            .fontWeight(.light)
        }

        if taskViewModel.isCurrentHour(task.taskDate) {
          HStack(spacing: 0) {
            HStack(spacing: -10) {
              ForEach(["Notorious", "Aline"], id: \.self) { username in
                Image(systemName: "person.circle")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 45, height: 45)
                  .clipShape(Circle())
                  .background(
                    Circle()
                      .stroke(.secondary, lineWidth: 5)

                  )
              }
            } //: HStack
            .hLeading()

            // MARK: - Check Button
            Button {

            } label: {
              Image(systemName: "checkmark")
                .foregroundStyle(.black)
                .padding(12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))

            }

          } //: HStack
          .padding(.top)
        }
      }
      .foregroundColor(taskViewModel.isCurrentHour(task.taskDate) ? .white : .black)
      .padding(taskViewModel.isCurrentHour(task.taskDate) ? 16 : 0)
      .padding(.bottom, taskViewModel.isCurrentHour(task.taskDate) ? 0 : 10)
      .hLeading()
      .background(
        Color.black
          .cornerRadius(25)
          .opacity(taskViewModel.isCurrentHour(task.taskDate) ? 1 : 0)
      )
    } //: HStack
    .hLeading()
  }

  // MARK: - Header View
  func HeaderView() -> some View {
    HStack(spacing: 12) {

      VStack(alignment: .leading, spacing: 12) {

        Text(Date().formatted(date: .abbreviated, time: .omitted))
          .foregroundColor(.gray)

        Text("Current Day")
          .font(.largeTitle)
          .fontWeight(.bold)

      } //: VStack
      .hLeading()

      Button {

      } label: {
        Image(systemName: "person.circle")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 45, height: 45)
          .clipShape(Circle())
      }

    } //: HStack
    .padding()
    .padding(.top, getSafeAreaInsets().top)
    .background(Color.white)
  }
}

struct Home_Previews: PreviewProvider {
  static var previews: some View {
    Home()
  }
}

// MARK: - UI Design Helper
extension View {

  func hLeading() -> some View {
    self
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  func hTrailing() -> some View {
    self
      .frame(maxWidth: .infinity, alignment: .trailing)
  }

  func hCenter() -> some View {
    self
      .frame(maxWidth: .infinity, alignment: .center)
  }

  // MARK: - Get Safe area insets
  func getSafeAreaInsets() -> UIEdgeInsets {
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let safeArea = screen.windows.first?.safeAreaInsets
    else {
      return .zero
    }

    return safeArea
  }
}
