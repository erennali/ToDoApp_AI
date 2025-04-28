import FirebaseFirestore
import SwiftUI
import FirebaseAuth

struct ToDoListView: View {
    
    @StateObject var viewModel: ToDoListViewViewModel
    @FirestoreQuery var items: [ToDoListItem]
    @State private var selectedItem: ToDoListItem?
    @State private var showingDetails = false
    @State private var showingDemoAlert = false
    @State private var isDemo = false
    @State private var showingRegisterView = false
    @State private var showingLoginView = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  
    init(userId: String) {
        if userId.isEmpty {
            self._items = FirestoreQuery(collectionPath: "users/e5qlBcxX0taiyO9B54ng4B9EfFS2/todos", predicates: [
                .order(by: "dueDate", descending: false)
            ])
            self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: "e5qlBcxX0taiyO9B54ng4B9EfFS2"))
        }else {
            self._items = FirestoreQuery(collectionPath: "users/\(userId)/todos", predicates: [
                .order(by: "dueDate", descending: false)
            ])
            self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
            
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isDemo {
                    // Demo kullanıcı mesajı
                    VStack(spacing: 20) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Demo Hesap")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Görevlerinizi yönetmek için lütfen bir hesap oluşturun veya giriş yapın.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            try? Auth.auth().signOut()
                            Auth.clearDemoUserData()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Çıkış Yap")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red.opacity(0.8), .orange.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // iPad için grid layout
                            if horizontalSizeClass == .regular {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 20),
                                    GridItem(.flexible(), spacing: 20)
                                ], spacing: 20) {
                                    // Bugünün görevleri
                                    if let todayItems = getTodayItems(), !todayItems.isEmpty {
                                        taskSection(
                                            title: "Bugünün Görevleri",
                                            items: todayItems,
                                            icon: "sun.max.fill"
                                        )
                                    }
                                    
                                    // Gelecek görevler
                                    let futureItems = items.filter { !isTodayTask($0) }
                                    if !futureItems.isEmpty {
                                        taskSection(
                                            title: "Gelecek Görevler",
                                            items: futureItems,
                                            icon: "calendar"
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                // iPhone için normal layout
                                // Bugünün görevleri
                                if let todayItems = getTodayItems(), !todayItems.isEmpty {
                                    taskSection(
                                        title: "Bugünün Görevleri",
                                        items: todayItems,
                                        icon: "sun.max.fill"
                                    )
                                }
                                
                                // Gelecek görevler
                                let futureItems = items.filter { !isTodayTask($0) }
                                if !futureItems.isEmpty {
                                    taskSection(
                                        title: "Gelecek Görevler",
                                        items: futureItems,
                                        icon: "calendar"
                                    )
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Görevler")
            .toolbar {
                Button {
                    if isDemo {
                        showingDemoAlert = true
                    } else {
                        viewModel.showingNewItemView = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: horizontalSizeClass == .regular ? 22 : 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(horizontalSizeClass == .regular ? 12 : 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .purple.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
            .sheet(item: $selectedItem) { item in
                DetailsItemView(item: item)
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView, alinanMetin: "")
            }
            .sheet(isPresented: $showingRegisterView) {
                RegisterView()
            }
            .sheet(isPresented: $showingLoginView) {
                LogInView()
            }
            .alert(isPresented: $showingDemoAlert) {
                Auth.showDemoAlert(
                    navigateToRegister: {
                        showingRegisterView = true
                    },
                    navigateToLogin: {
                        showingLoginView = true
                    }
                )
            }
        }
        .environment(\.locale, Locale(identifier: "tr_TR"))
        .onAppear {
            checkDemoStatus()
        }
    }
    
    private func checkDemoStatus() {
        Auth.isDemoUser { isDemoUser in
            DispatchQueue.main.async {
                isDemo = isDemoUser
            }
        }
    }
    
    private func taskSection(title: String, items: [ToDoListItem], icon: String) -> some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 20 : 15) {
            // Section Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: horizontalSizeClass == .regular ? 28 : 24))
                    .foregroundColor(.blue)
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2 : .title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Tasks
            LazyVStack(spacing: horizontalSizeClass == .regular ? 15 : 12) {
                ForEach(items) { item in
                    ToDoListItemView(item: item)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                            showingDetails = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.delete(id: item.id)
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                selectedItem = item
                                showingDetails = true
                            } label: {
                                Label("Detaylar", systemImage: "info.circle")
                            }
                            .tint(.blue)
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 15 : 10)
    }
    
    // Bugün yapılması gereken görevleri al
    private func getTodayItems() -> [ToDoListItem]? {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "tr_TR")
        let todayStart = calendar.startOfDay(for: Date()) // Bugünün başlangıcını al
        let todayStartTimeInterval = todayStart.timeIntervalSince1970 // TimeInterval'e dönüştür
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)?.timeIntervalSince1970 ?? todayStartTimeInterval
        
        return items.filter { $0.dueDate >= todayStartTimeInterval && $0.dueDate < todayEnd }
    }
    
    // Bugün yapılan görevleri kontrol et
    private func isTodayTask(_ item: ToDoListItem) -> Bool {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "tr_TR")
        let todayStart = calendar.startOfDay(for: Date()) // Bugünün başlangıcını al
        let todayStartTimeInterval = todayStart.timeIntervalSince1970 // TimeInterval'e dönüştür
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)?.timeIntervalSince1970 ?? todayStartTimeInterval
        
        return item.dueDate >= todayStartTimeInterval && item.dueDate < todayEnd
    }
}
#Preview {
    ToDoListView(userId: "M84dZMIbrjcRpWbNe2g9K4SSJ2r1")
}

