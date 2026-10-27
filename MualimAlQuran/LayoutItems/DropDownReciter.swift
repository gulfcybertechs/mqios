import SwiftUI

struct DropDownReciter: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @State var dropDownExpanded = false
    @State var dropDownItems: [(String, String)] = []
    @State var dropDownSelected: String = ""
    @State var dropDownSelectedText: String = ""
    @AppStorage("language") var currentLanguage = getLanguage()
    
    var body: some View {
       
        VStack {
            
            Menu {
                
                Picker(dropDownSelected, selection: Binding(
                    get: { dropDownSelected },
                    set: { value in
                        AppHaptics.tap()
                        dropDownSelected = value
                    }
                )) {
                    
                    ForEach(dropDownItems, id: \.0) { item in
                        
                        Text(getReciterAr(id: item.0))
                    }
                }
                .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
                .onChange(of: dropDownSelected) { _, value in
                    
                    setReciter(id: dropDownSelected)
                    dropDownSelectedText = getReciter(mvm: mvm).1
                }
                
            } label: {
                
                HStack {
                    
                    Text(getReciterAr(id: dropDownSelected))
                        .font(currentLanguage == "Ar" ? .system(size: 16, weight: .bold) : .custom(hafs(), size: 16))
                        .foregroundColor(colorResource.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .padding(10)                        
                    
                    Spacer()
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 8, height: 6)
                        .padding(10)
                        .foregroundStyle(colorResource.white)
                        
                }
            }
            .simultaneousGesture(TapGesture().onEnded { AppHaptics.tap() })
        }
        .onAppear {
            dropDownItems = recitersList(mvm: mvm)
            dropDownSelected = getReciter(mvm: mvm).0
            dropDownSelectedText = getReciter(mvm: mvm).1
        }
    }
}
