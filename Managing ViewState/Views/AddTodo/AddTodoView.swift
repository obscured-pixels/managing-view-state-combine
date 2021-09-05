import SwiftUI

struct AddTodoView: View {
    @StateObject
    private var viewModel = ViewModel()
    @State
    private var title: String = ""
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter A Title Here", text: $title)
                        .onChange(of: title) { _ in
                            viewModel.send(.validate(title: title))
                        }
                }

                Section {
                    Button(action: {
                        viewModel.send(.addTodo(title: title))
                    }) {
                        if viewModel.viewState.loading {
                            ProgressView()
                        } else {
                            Text("Submit")
                        }
                    }
                    .disabled(!viewModel.viewState.valid || viewModel.viewState.loading)
                }
            }
            .navigationBarTitle("Add Todo", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                viewModel.subscribe()
            }
            .onReceive(viewModel.$viewState) { viewState in
                /**
                 For a more elegant approach to programattic navigation in SwiftUI, check out my other article:
                 "Abstracing Navigation in SwiftUI"  https://obscuredpixels.com/abstracting-navigation-in-swiftui
                 */
                if viewState.dismiss {
                    presentation.wrappedValue.dismiss()
                }
            }
        }

    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView()
    }
}
