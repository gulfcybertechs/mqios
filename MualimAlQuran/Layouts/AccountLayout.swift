import SwiftUI

struct AccountLayout: View {        
    
    @EnvironmentObject var navigation: AppNavigationRouter
    @EnvironmentObject var mvm: MainViewModel
    @Binding var vm: AccountViewModel    

    var callback : (() -> Void)? = nil
    
    var date = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
        
        GeometryReader { geo in
            
            let screenWidth = UIScreen.main.bounds.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing - 50
            
            ScrollViewReader { scrollView in
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        //region Header
                        VStack(spacing: 0)
                        {
                            Spacer().frame(height: 40)
                            
                            HStack(alignment: .bottom, spacing: 0) {
                                
                                VStack(spacing: 0) {
                                    
                                    Text(getUser(type: "Name"))
                                        .font(currentLanguage == "Ar" ? .system(size: 26, weight: .bold) : .custom("opensans", size: 26))
                                        .fontWeight(currentLanguage == "Ar" ? .bold : .medium)
                                        .foregroundStyle(Color.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(getUser(type: "Email"))
                                        .font(currentLanguage == "Ar" ? .system(size: 18, weight: .regular) : .custom("opensans", size: 18))
                                        .foregroundStyle(colorResource.maroon)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(alignment: .leading)
                                
                                Spacer()
                                
                                Button(
                                    action: {
                                        Task {
                                            if (callback != nil) {
                                                callback!()
                                            }
                                        }
                                    })
                                {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(colorResource.lightButtonText)
                                        .font(.system(size: 24))
                                }
                                .frame(width: 38, height: 38)
                                .padding(8)
                                .background(colorResource.lightButton)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            Spacer().frame(height: 20)
                        }
                        .padding(.trailing, 5)
                        //endregion
                        
                        if (date.year == 2024 && date.month == 10 && date.day! <= 23) {
                            //region Delete Account
                            VStack(spacing: 0) {
                                
                                Text("If you would like to delete your account and all associated data, please [click here](https://mualim-alquran.com/delete-account)")
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(colorResource.lightButton)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .padding(.bottom, 10)
                            //endregion
                        }
                        
                        ZStack {
                            
                            if (mvm.memorizingItems.isEmpty) {
                                
                                VStack(spacing: 0) {
                                    
                                    if (!vm.sync) {
                                        
                                        Text("You haven't memorized anything yet!")
                                            .frame(maxWidth: .infinity)
                                            .padding(10)
                                            .background(colorResource.lightButton)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                    else{
                                        
                                        ProgressView()
                                    }
                                }
                                
                            }
                            else {
                                
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 1000), alignment: .leading)], spacing: 0) {
                                    
                                    
                                    ForEach($mvm.memorizingItems.filter { $0.isTab.wrappedValue }) { tabItem in
                                        
                                        Section(header: ListTabItem(item: .constant(ListModel(Title: "\(tabItem.Surah.wrappedValue) \((currentLanguage == "Ar") ? mvm.verseByVerse.first{ $0.Surah == tabItem.Surah.wrappedValue }!.SurahNameAr : tabItem.SurahName.wrappedValue)", TabIndex: tabItem.TabIndex.wrappedValue)), account: .constant(true), callBack: {
                                            
                                            Task {
                                                
                                                if (tabItem.TabIndex.wrappedValue == mvm.stageTab.TabIndex) {
                                                    mvm.stageTab = ListModel(isTab: true, TabIndex: "0")
                                                } else {
                                                    mvm.stageTab = ListModel(isTab: tabItem.isTab.wrappedValue, TabIndex: tabItem.TabIndex.wrappedValue)
                                                }
                                                
                                                try? await Task.sleep(nanoseconds: 300_000_000)
                                                
                                                withAnimation {
                                                    scrollView.scrollTo(tabItem.id, anchor: .top)
                                                }
                                            }
                                            
                                        })) {
                                            
                                            ForEach($mvm.memorizingItems.filter { !$0.isTab.wrappedValue && $0.TabIndex.wrappedValue == tabItem.TabIndex.wrappedValue }) { item in
                                                
                                                let show = if (mvm.stageTab.TabIndex != item.TabIndex.wrappedValue) {
                                                    false
                                                }
                                                else {
                                                    true
                                                }
                                                
                                                if (show) {
                                                    
                                                    HStack(spacing: 0)
                                                    {
                                                        VStack(spacing:0) {
                                                            Text((currentLanguage == "Ar") ? "من آية" : "From Verse:").frame(maxWidth: .infinity, alignment: .leading)
                                                            Text(item.FromAyah.wrappedValue)
                                                                .fontWeight(.bold)
                                                                .foregroundStyle(colorResource.maroon)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        .frame(width: screenWidth * 0.35)
                                                        
                                                        VStack(alignment: .leading, spacing:0) {
                                                            Text((currentLanguage == "Ar") ? "إلى آية" : "To Verse:").frame(maxWidth: .infinity, alignment: .leading)
                                                            Text(item.ToAyah.wrappedValue)
                                                                .fontWeight(.bold)
                                                                .foregroundStyle(colorResource.maroon)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        .frame(width: screenWidth * 0.35)
                                                        
                                                        VStack(spacing:0) {
                                                            
                                                            HStack(spacing: 0) {
                                                                    
                                                                Button(action: {
                                                                    
                                                                    let lessonItem = mvm.stages.first { $0.id == 7 }!
                                                                    lessonItem.StageID = 7
                                                                    
                                                                    lessonItem.FromMemorizing = true
                                                                    lessonItem.MemorizingSurah = item.Surah.wrappedValue
                                                                    lessonItem.MemorizingSurahName = item.SurahName.wrappedValue
                                                                    lessonItem.MemorizingAyah = item.FromAyah.wrappedValue
                                                                    
                                                                    mvm.recitationInitialLoad = false
                                                                    mvm.listType = "recitation"
                                                                    mvm.listSelected = mvm.stages.first { $0.id == 7 }!
                                                                    mvm.lessonSelected = lessonItem
                                                                    mvm.recitationItems = mvm.verse1
                                                                                                                                        
                                                                    navigation.setPath([.recitation(stageID: 7)], in: .home)
                                                                    mvm.selectedTab = Tab.home
                                                                                                                                                                                                            
                                                                }) {
                                                                    
                                                                    Image(systemName: (currentLanguage == "Ar") ? "arrow.left" : "arrow.right")
                                                                        .foregroundStyle(Color.white)
                                                                        .font(.system(size: 18))
                                                                        .padding(5)
                                                                }
                                                                .buttonStyle(.borderedProminent)
                                                                
                                                            }
                                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                                            
                                                        }
                                                        .frame(width: screenWidth * 0.30)
                                                        
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(10)
                                                    .background(Color(hex: "F1F1EB"))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .onAppear() {
                        loadMemorizing(vm: vm, mvm: mvm)
                    }
                    .task(id: getMemorizing().count) {
                        loadMemorizing(vm: vm, mvm: mvm)
                    }
                }
                .padding(.top, 1)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

func loadMemorizing(vm: AccountViewModel, mvm: MainViewModel) {
    
    var newListData: [Memorizing] = []
    vm.sync = true

    let localData = getMemorizing().filter { it in it.UserID == getUser(type: "ID") }
        .sorted { Int($0.Surah)! < Int($1.Surah)! }
        .sorted { Int($0.Ayah)! < Int($1.Ayah)! }
    
    var localDataGrouped: [Memorizing] = []
    
    localData.forEach { it in
        
        if (localDataGrouped.filter { $0.SurahName == it.SurahName }.isEmpty) {
            localDataGrouped.append(it)
        }
    }

    var index = 101
    localDataGrouped.forEach { it in

        var tabVisible = false
        if (index == 101) {
            tabVisible = true
        }

        let dsAyah = localData.filter { it1 in it1.UserID == getUser(type: "ID") && it1.SurahName == it.SurahName }
            .sorted { Int($0.Ayah)! < Int($1.Ayah)! }

        newListData.append(
            Memorizing(
                Surah: dsAyah[0].Surah,
                SurahName: it.SurahName,
                isTab: true,
                TabIndex: index.description,
                TabVisible: tabVisible
            )
        )

        var _Progress: [Memorizing] = []

        var i = 0

        while (i < dsAyah.count) {

            let StartIndex = i
            var EndIndex = i

            while (true) {

                let _1 = Int(dsAyah[EndIndex].Ayah)! + 1
                var _2 = -1
                if (EndIndex + 1 < dsAyah.count) {
                    _2 = Int(dsAyah[EndIndex + 1].Ayah)!
                }

                if (_1 == _2) {
                    EndIndex+=1
                    i+=1
                } else {
                    break
                }
            }

            _Progress.append(
                Memorizing(
                    Surah: dsAyah[StartIndex].Surah,
                    SurahName: dsAyah[StartIndex].SurahName,
                    Ayah: dsAyah[StartIndex].Ayah,
                    FromAyah: dsAyah[StartIndex].Ayah,
                    ToAyah: dsAyah[EndIndex].Ayah
                )
            )

            i+=1
        }

        _Progress.forEach { it in

            newListData.append(
                Memorizing(
                    Surah: it.Surah,
                    SurahName: it.SurahName,
                    Ayah: it.Ayah,
                    FromAyah: it.FromAyah,
                    ToAyah: it.ToAyah,
                    TabIndex: index.description,
                    TabVisible: tabVisible
                )
            )
        }

        index+=1
    }

    mvm.memorizingItems.removeAll()
    mvm.memorizingItems = newListData
    vm.sync = false //Android
}
