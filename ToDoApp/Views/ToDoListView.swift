import FirebaseFirestore
import SwiftUI

struct ToDoListView: View {
    
    @StateObject var viewModel: ToDoListViewViewModel
    @FirestoreQuery var items: [ToDoListItem]
    
    init(userId: String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/todos", predicates: [
            .order(by: "dueDate", descending: false)
        ])
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Bugünün görevlerini al
                if let todayItems = getTodayItems(), !todayItems.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Bugünün Görevleri")
                            .font(.headline)
                            .padding(.leading)
                        
                        List(todayItems) { item in
                            ToDoListItemView(item: item)
                                .swipeActions {
                                    Button("Sil") {
                                        viewModel.delete(id: item.id)
                                    }
                                    .background(Color.red)
                                }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                // Bugün dışındaki görevler
                VStack(alignment: .leading) {
                    Text("Gelecek Görevler")
                        .font(.headline)
                        .padding(.leading)
                }
                List(items.filter { !isTodayTask($0) }) { item in
                    ToDoListItemView(item: item)
                        .swipeActions {
                            Button("Sil") {
                                viewModel.delete(id: item.id)
                            }
                            .background(Color.red)
                        }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Görevler")
            .toolbar {
                Button {
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView, alinanMetin: "")
            }
        }
    }
    
    // Bugün yapılması gereken görevleri al
    private func getTodayItems() -> [ToDoListItem]? {
        let todayStart = Calendar.current.startOfDay(for: Date()) // Bugünün başlangıcını al
        let todayStartTimeInterval = todayStart.timeIntervalSince1970 // TimeInterval'e dönüştür
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)?.timeIntervalSince1970 ?? todayStartTimeInterval
        
        return items.filter { $0.dueDate >= todayStartTimeInterval && $0.dueDate < todayEnd }
    }
    
    // Bugün yapılan görevleri kontrol et
    private func isTodayTask(_ item: ToDoListItem) -> Bool {
        let todayStart = Calendar.current.startOfDay(for: Date()) // Bugünün başlangıcını al
        let todayStartTimeInterval = todayStart.timeIntervalSince1970 // TimeInterval'e dönüştür
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)?.timeIntervalSince1970 ?? todayStartTimeInterval
        
        return item.dueDate >= todayStartTimeInterval && item.dueDate < todayEnd
    }
}
#Preview {
    ToDoListView(userId: "M84dZMIbrjcRpWbNe2g9K4SSJ2r1")
}

