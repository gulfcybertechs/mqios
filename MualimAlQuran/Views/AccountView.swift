import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var loader = true
    @Published var initial = false
    @Published var sync = false
    @Published var items = [Memorizing()]
}

struct AccountView: View {
    
    @EnvironmentObject var mvm: MainViewModel    
    @StateObject var vm = AccountViewModel()
    @AppStorage("UserID") var userID = ""
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if (userID != "") {
                
                AccountLayout(vm:.constant(vm)) {
                                                        
                    removeUser()
                    vm.items = []
                    vm.initial = false
                    vm.sync = false
                    vm.loader = true
                    userID = ""
                }
            }
            else {
                
                LoginLayout() { it in
                    
                    setUser(item: it)

                    let user = it.data![0]
                    
                    vm.items = []
                    vm.initial = false
                    vm.sync = true
                    vm.loader = true
                    
                    if (user.BookmarkSurah != nil && user.BookmarkAyah != nil) {
                        if (user.BookmarkSurah != "" && user.BookmarkAyah != "" && getBookmark(key: "Surah", mvm: mvm) == "" && getBookmark(key: "Ayah", mvm: mvm) == "") {
                            
                            setBookmark(id: user.BookmarkID!, surah: user.BookmarkSurah!, surahName: user.BookmarkSurahName!, ayah: user.BookmarkAyah!)
                        }
                    }
                    
                    userID = user.id
                    
                    Task.detached { @MainActor in
                                                
                        await syncMemorizing(vmAccount: vm, mvm: mvm)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear() {
            
            mvm.viewLevel = mvm.accountViewLevel
            userID = getUser(type: "ID")
        }
    }
}
