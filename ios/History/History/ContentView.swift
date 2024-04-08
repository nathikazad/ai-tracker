//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI
import Charts

class ContentViewModel: ObservableObject {
    @Published var showChat: Bool = Authentication.shared.hasuraJwt == nil
}

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    
    var body: some View {
            ZStack(alignment: .bottom) {
                TabView {
                    TodosView()
                        .tabItem {
                            Image(systemName: "checklist")
                            Text("Todos")
                        }
                    
                    LogsView()
                        .tabItem {
                            Image(systemName: "clock")
                            Text("Timeline")
                        }
                    
                    Text("") // Placeholder for the center button
                    
                    GoalsView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Goals")
                        }
                    
                    GraphsView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Graphs")
                        }
                }
                
                // Center button overlay
                Button(action: {
                    // Perform your action here
                    print("Center button tapped!")
                }) {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(radius: 4)
                }
                .offset(y: -30) // Adjust this offset if necessary
                .padding(.bottom, -30) // This negates half of the button's height to align it properly
            }
        }
    }

    // Define your custom views for each tab
struct LogsView: View {
    let schedule = [
        ("5:30 am", "Woke up"),
        ("7:00 am", "Arrived at work"),
        ("10:00 am - 10:45 am", "Gym 45 minutes"),
        ("12:00 pm - 12:20 pm", "Practiced French"),
        ("6:30 pm", "Left Work"),
        ("7:00 pm", "Arrived home"),
        ("7:30 pm - 8:30 pm", "Cooked Potato Curry"),
        ("8:30 pm - 9:30 pm", "Danced"),
        ("10:30 pm", "Went to sleep")
    ]
    var body: some View {
        NavigationView {
            List {
                ForEach(schedule, id: \.0) { time, activity in
                    HStack {
                        Text(time)
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        Text(activity)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Timeline")
        }
    }
}


struct TodosView: View {
        @State private var tasks = [
            ("Morning meeting", false),
            ("Check emails", false),
            ("Go running", false),
            ("Discuss marketing", false)
        ]
        
        var body: some View {
            NavigationView {
                List {
                    ForEach($tasks, id: \.0) { $task in
                        HStack {
                            Button(action: {
                                task.1.toggle()
                            }) {
                                HStack {
                                    Image(systemName: task.1 ? "checkmark.square.fill" : "square")
                                        .foregroundColor(task.1 ? .blue : .gray)
                                    Text(task.0)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .navigationTitle("Todos")
            }
            
        }
    }

struct GoalsView: View {
    let goals = [
        ("Wake up at 5:30 am", "Everyday"),
        ("Cooking", "Sunday, Wednesday, Friday"),
        ("Workout", "Twice a day"),
        ("Pray", "Five times a day"),
        ("Call Mom", "Once a week"),
        ("Practice French", "Everyday 20 minutes"),
        ("Practice Dance", "Everyday 1 hour"),
        ("Sleep at 10:30 PM", "Everyday")
    ]
        
    var body: some View {
            NavigationView {
                List(goals, id: \.0) { activity, frequency in
                    VStack(alignment: .leading) {
                        Text(activity)
                            .font(.headline)
                        Text(frequency)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Goals")
            }
        }
    }


struct GraphsView: View {
    
    let graphs: [GraphConfig] = [
        GraphConfig(type: .line, data: [
            ("M", 7.5),
            ("T", 8.5),
            ("W", 7.75),
            ("Th", 8.15),
            ("F", 9.15),
            ("S", 7.7)
        ], title: "Wake Up Time", ruleMarkValue: 8.5, ruleMarkLabel: "8:30 am"),
        
        GraphConfig(type: .bar, data: [
            ("M", 5),
            ("T", 4),
            ("W", 3),
            ("Th", 5),
            ("F", 1),
            ("S", 3)
        ], title: "Number of Prayers", ruleMarkValue: 5, ruleMarkLabel: "5")
    ]
    
    var body: some View {
          NavigationView {
              ScrollView {
                  VStack(alignment: .leading) {
                      ForEach(graphs.indices, id: \.self) { index in
                          VStack(alignment: .leading) {
                              Text(graphs[index].title)
//                                  .font(.title2)
                                  .padding(.top, index == 0 ? 20 : 40) // Add space at the top for the first item, more for others
                                  .padding(.bottom, 15)
                              
                              graphs[index].chartView()
                                  .frame(height: 100) // Adjust height as necessary
                          }
                          .padding(.horizontal)
                      }
                  }
              }
              .navigationTitle("Graphs")
          }
      }
}
    // Preview for ContentView

#Preview {
    ContentView(contentViewModel: ContentViewModel())
}




// Define the types of graphs
enum GraphType {
    case line, bar
}

// Graph configuration model
struct GraphConfig {
    var type: GraphType
    var data: [(day: String, time: Double)]
    var title: String
    var ruleMarkValue: Double?
    var ruleMarkLabel: String?
}

// Extend the model to include a method to generate the chart
extension GraphConfig {
    @ViewBuilder
    func chartView() -> some View {
        switch type {
        case .line:
            Chart {
                ForEach(data, id: \.day) { entry in
                    LineMark(
                        x: .value("Day", entry.day),
                        y: .value("Time", entry.time)
                    )
                }
                if let ruleValue = ruleMarkValue, let label = ruleMarkLabel {
                    RuleMark(
                        y: .value("Guide", ruleValue)
                    )
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYScale(domain: data.map { $0.time }.min()!...data.map { $0.time }.max()!)
            
        case .bar:
            Chart {
                ForEach(data, id: \.day) { entry in
                    BarMark(
                        x: .value("Day", entry.day),
                        y: .value("Time", entry.time)
                    )
                }
                if let ruleValue = ruleMarkValue, let label = ruleMarkLabel {
                    RuleMark(
                        y: .value("Guide", ruleValue)
                    )
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYScale(domain: 0...data.map { $0.time }.max()!)
        }
    }
}


//
//NavigationStack {
//    ZStack {
//        VStack {
//            // Toggle Button for Expandable Widget
//            DailyRemindersView()
//            InteractionsView()
//            BottomBar()
//        }
//    }
//    .navigationTitle("Observe and Improve")
//    .navigationBarTitleDisplayMode(.inline)
//    .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button {
//                Authentication.shared.signOut()
//                contentViewModel.showChat = true
//            } label: {
//                Text("Signout")
//                    .foregroundColor(.red)
//            }
//        }
//    }
//    .onAppear(perform: {
//        HasuraSocket.shared.setBackgroundNotifiers(didEnterBackgroundNotification: UIApplication.didEnterBackgroundNotification, willEnterForegroundNotification: UIApplication.willEnterForegroundNotification)
//        HasuraSocket.shared.setup()
//    })
//}
//.fullScreenCover(isPresented: $contentViewModel.showChat) {
//    ChatView(contentViewModel: contentViewModel)
//}
