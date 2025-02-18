//
//  NewItemView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct NewItemView: View {
    @Binding var newItemPresented : Bool
    @StateObject private var viewModel: NewItemViewViewModel
    let alinanMetin: String // Constructor'dan alınan veri
    
    
    init(newItemPresented: Binding<Bool>, alinanMetin: String) {
            self._newItemPresented = newItemPresented
            self.alinanMetin = alinanMetin
            
            // ViewModel'i alınan metinle başlat
            _viewModel = StateObject(
                wrappedValue: NewItemViewViewModel(initialTitle: alinanMetin)
            )
        }
    
    
    var body: some View {
        VStack {
            Text("Yeni Görev")
                .font(.title)
                .bold()
                .padding(.top,70)
            Form {
                TextField("Başlık",text:$viewModel.title)
                    .padding(.bottom)
                 
                TextField("Açıklama", text:$viewModel.description,axis: .vertical)
                    .frame(height: 170 ,alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                    
                    
                DatePicker("Bitiş Tarihi",selection: $viewModel.dueDate)
                    .datePickerStyle(.compact)
                    
                Toggle(
                        "Alarm Kur",
                        systemImage: "clock.badge",
                        isOn: $viewModel.onClock
                    )
                
                BigButton(title: "Kaydet"){
                    if viewModel.canSave {
                        viewModel.save()
                        newItemPresented = false
                    }else {
                        viewModel.showAlert = true
                    }
                   
                }
                .padding(.top)
                
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Hata"),message: Text("Lütfen verilerin doğruluğunu kontrol ediniz."))
            }
            
        }
    }
}

#Preview {
    NewItemView(newItemPresented: Binding(get: {
        return true
    }, set: { _ in
        
    }), alinanMetin: "Test")
}
