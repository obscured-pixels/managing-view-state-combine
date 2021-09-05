import SwiftUI

struct TodoListView: View {
    @StateObject
    private var viewModel = ViewModel()
    @State
    private var showAddTodoSheet = false
    var body: some View {
        NavigationView {
            content(viewModel.viewState)
                .navigationTitle("Todos")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showAddTodoSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddTodoSheet) {
                    AddTodoView()
                }
        }
        .onAppear {
            viewModel.subscribe()
        }
    }

    @ViewBuilder
    private func content(_ state: ViewState) -> some View {
        switch state {
        case .loading:
            ProgressView()
        case .error:
            Text("Oops something went wrong")
                .padding()
        case .content(let todos):
            List {
                ForEach(todos) { todo in
                    Text(todo.title)
                }
                .onDelete { indextSet in
                    viewModel.send(.removeTodos(indextSet))
                }
            }
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
