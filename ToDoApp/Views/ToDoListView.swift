//
//  ToDoListView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//
import FirebaseFirestore
import SwiftUI

struct ToDoListView: View {
    
    @StateObject var viewModel : ToDoListViewViewModel
    @FirestoreQuery var items : [ToDoListItem]
 
    
    init (userId:String) {
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/todos")
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        
        NavigationView(){
            VStack{
                List(items){item in
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
            .toolbar{
                Button{
                    //sheet açma
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView)
            }
        }
    }
}

#Preview {
    ToDoListView(userId: "M84dZMIbrjcRpWbNe2g9K4SSJ2r1")
}
