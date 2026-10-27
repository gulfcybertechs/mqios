import SwiftUI

struct ListItem: View {
    
    @AppStorage("language") var currentLanguage = getLanguage()
    @Binding var item: ListModel

    private var titleFont: Font {
        if currentLanguage == "Ar" {
            return .system(size: 20, weight: .bold)
        }
        return .custom("opensans", size: 20)
    }
    
    var body: some View {
                            
            VStack(spacing: 0) {
                
                listImage(name: item.Image)
                    .resizable()
                    .aspectRatio( contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color(.lightGray), radius: 30, y: 30)
                
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.95))
                    .frame(height: 100, alignment: .center)
                    .overlay(
                        
                        VStack(spacing: 0) {
                            
                            Spacer()
                            
                            let title = item.Title.components(separatedBy: "<span>")
                            
                            Text(title[0])
                                .font(titleFont)
                                .foregroundColor(.black)
                                .bold()
                            
                            if (title.count > 1) {
                                
                                Text(title[1].replacingOccurrences(of: "</span>", with: ""))
                                    .font(titleFont)
                                    .foregroundColor(colorResource.maroon)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            Rectangle().frame(height: 1)
                                .foregroundColor(colorResource.orange)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .offset(y:-50)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
    }
}
