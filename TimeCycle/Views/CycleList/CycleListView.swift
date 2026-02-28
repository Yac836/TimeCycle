import SwiftUI
import SwiftData

/// 循环列表视图 - 展示所有已创建的时间循环
struct CycleListView: View {

    @Query(
        filter: #Predicate<TimeCycle> { !$0.isArchived },
        sort: \TimeCycle.sortOrder
    )
    private var cycles: [TimeCycle]

    @Environment(\.modelContext) private var modelContext
    @State private var showingNewCycle = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(cycles) { cycle in
                    NavigationLink(value: cycle) {
                        CycleRowView(cycle: cycle)
                    }
                }
                .onDelete(perform: deleteCycles)
            }
            .navigationTitle("时间循环")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewCycle = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: TimeCycle.self) { cycle in
                CycleDetailView(cycle: cycle)
            }
            .sheet(isPresented: $showingNewCycle) {
                CycleEditView(modelContext: modelContext)
            }
            .overlay {
                if cycles.isEmpty {
                    emptyStateView
                }
            }
        }
    }

    /// 删除循环（软删除，标记为归档）
    private func deleteCycles(at offsets: IndexSet) {
        for index in offsets {
            cycles[index].isArchived = true
        }
        try? modelContext.save()
    }

    /// 空状态提示
    private var emptyStateView: some View {
        ContentUnavailableView(
            "还没有循环",
            systemImage: "timer",
            description: Text("点击右上角 + 创建你的第一个时间循环")
        )
    }
}