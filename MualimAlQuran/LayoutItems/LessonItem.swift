import SwiftUI
//import AVFoundation
//import RichText

struct LessonItem: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @EnvironmentObject var sheetVM: BottomSheetViewModel
    @Binding var item: LessonModel
    @Binding var activeLetter: Int
    @ObservedObject var player: Player
    @AppStorage("language") var currentLanguage = getLanguage()
    
    @State var alert = false
        
    var body: some View {
        
        Button(action: {
            
            if (mvm.lessonSelected.Number == 2 && !item.section) {
                
            } else if (mvm.lessonSelected.Number == 7) {
                                
                sheetVM.title = item.Trans
                sheetVM.summary = item.Arti

                sheetVM.videoUrl = item.id.description
                sheetVM.showVideo = true

                sheetVM.sheetState = true
                
            } else {
                
                let navigationRevision = AppNavigationAudio.revision
                Task { @MainActor in
                    guard AppNavigationAudio.revision == navigationRevision else { return }
                                                                
                    if (activeLetter == item.id) {
                        
                        player.stop()
                    }
                    else {
                        
                        activeLetter = item.id
                        
                        alert = await letterPlay(lesson: mvm.lessonSelected, item: item, player: player, navigationRevision: navigationRevision)
                    }
                }
            }
            
        }) {
            
            VStack(spacing: 0) {
                
                var minHeight: CGFloat {
                    
                    if (mvm.lessonSelected.Number == 7) {
                        return 1
                    } else if (mvm.lessonSelected.Number == 5) {
                        return 190
                    } else if (mvm.lessonSelected.Number >= 11 && mvm.lessonSelected.Number != 17) {
                        // No sizing required
                        if (mvm.lessonSelected.Number == 11 || mvm.lessonSelected.Number == 12 || mvm.lessonSelected.Number == 13 || mvm.lessonSelected.Number == 15 || mvm.lessonSelected.Number == 16) {
                            return 250
                        }
                        if (mvm.lessonSelected.Number == 13) {
                            return 190
                        }
                        if (mvm.lessonSelected.Number == 13 && item.id >= 9) {
                            return 260
                        }
                        else {
                            return 1
                        }
                    } else if (mvm.lessonSelected.Number == 17) {
                        return 250
                    } else {
                        return 250
                    }
                    
                    /*if (lesson.Number == 7 || lesson.Number == 5 || lesson.Number == 9)  {
                        return 1
                    }
                    else if (lesson.Number >= 11 && lesson.Number != 17) {
                        return 1
                    }
                    else {
                        return 250
                    }*/
                }
                
                var maxHeight: CGFloat {
                    
                    if (mvm.lessonSelected.Number == 7) {
                        return 250
                    } else if (mvm.lessonSelected.Number == 5) {
                        return 250
                    } else if (mvm.lessonSelected.Number == 17) {
                        return 300
                    } else {
                        return 2500
                    }
                    
                    /*if (lesson.Number == 7 || lesson.Number == 5 || lesson.Number == 9)  {
                        return 250
                    }
                    else if (lesson.Number >= 11 && lesson.Number != 17) {
                        return .infinity
                    }
                    else {
                        return 250
                    }*/
                }
                
                ZStack {
                    
                    let letterImage = letterImage(lesson: mvm.lessonSelected, item: item, activeLetter: activeLetter)
                    
                    if (letterImage != nil) {
                        
                        Image(uiImage: letterImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(mvm.lessonSelected.Number == 3 ? 30 : 0)
                    }
                    else {
                        
                        if (mvm.lessonSelected.Number == 2 && (item.id == 109 || item.id == 182 || item.id == 183 || item.id == 184)) {
                            
                            VStack(spacing: 0) {
                                
                                VStack(spacing: 0) {
                                    
                                    Text(item.LetterFragment1)
                                        .font(.custom("ScheherazadeNew-Regular", size: 75))
                                        .foregroundColor(letterColor(item: item, activeLetter: activeLetter, lesson: mvm.lessonSelected))
                                        .offset(y: CGFloat(Double(item._TopFr1)!))
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                    
                                }.frame(height: 85)
                                
                                Rectangle()
                                    .frame(height:1)
                                    .foregroundColor(activeLetter == item.id ? colorResource.white : colorResource.ee)
                                
                                VStack(spacing: 0) {
                                    
                                    Text(item.LetterFragment2)
                                        .font(.custom("ScheherazadeNew-Regular", size: 75))
                                        .foregroundColor(letterColor(item: item, activeLetter: activeLetter, lesson: mvm.lessonSelected))
                                        .offset(y: CGFloat(Double(item._TopFr2)!))
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                    
                                }.frame(height: 85)
                                
                                Rectangle()
                                    .frame(height:1)
                                    .foregroundColor(activeLetter == item.id ? colorResource.white : colorResource.ee)
                                
                                VStack(spacing: 0) {
                                    
                                    if (item.id != 182) {
                                        
                                        Text(item.LetterFragment3)
                                            .font(.custom("ScheherazadeNew-Regular", size: 75))
                                            .foregroundColor(letterColor(item: item, activeLetter: activeLetter, lesson: mvm.lessonSelected))
                                            .offset(y: CGFloat(Double(item._TopFr3)!))
                                            .padding(.leading, 5)
                                            .padding(.trailing, 5)
                                    }
                                    
                                }.frame(height: 85)
                            }
                            
                        }
                        else {
                            
                            var attributedString: AttributedString {
                                
                                let string = item.Letter
                                var attributedString = AttributedString(string)
                                
                                if (mvm.lessonSelected.Number == 3 && activeLetter != item.id) {
                                    
                                    if (item.Letter.count > 1) {
                                        
                                        if let range = attributedString.range(of: string[1]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: item.id + 1))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 2) {
                                        
                                        if let range = attributedString.range(of: string[2]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: item.id + 2))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 3) {
                                        
                                        if let range = attributedString.range(of: string[3]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: item.id + 3))
                                        }
                                    }
                                }
                                
                                if (mvm.lessonSelected.Number == 8 && activeLetter != item.id) {
                                    
                                    if let range = attributedString.range(of: string[0]) {
                                        attributedString[range].foregroundColor = Color(hex: letterColor(id: 2))
                                    }
                                    
                                    if (item.Letter.count > 1) {
                                        
                                        if let range = attributedString.range(of: string[1]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: 3))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 2) {
                                        
                                        if let range = attributedString.range(of: string[2]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: 3))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 3) {
                                        
                                        if let range = attributedString.range(of: string[3]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: 3))
                                        }
                                    }
                                }
                                
                                if (mvm.lessonSelected.Number == 10 && item.id != 76 && item.id != 77 && item.id != 78) {
                                    
                                    if let range = attributedString.range(of: string[0]) {
                                        attributedString[range].foregroundColor = Color(hex: letterColor(id: 2))
                                    }
                                    
                                    var colorID: Int { 
                                        if (1...3 ~= item.id) {
                                            return 7
                                        }
                                        else if (4...6 ~= item.id) {
                                            return 8
                                        }
                                        else if (10...12 ~= item.id) {
                                            return 7
                                        }
                                        else if (19...21 ~= item.id) {
                                            return 7
                                        }
                                        else if (25...27 ~= item.id) {
                                            return 3
                                        }
                                        else if (43...45 ~= item.id) {
                                            return 7
                                        }
                                        
                                        if (49...51 ~= item.id) {
                                            return 7
                                        }
                                        else if (52...54 ~= item.id) {
                                            return 8
                                        }
                                        else if (58...60 ~= item.id) {
                                            return 7
                                        }
                                        else if (70...72 ~= item.id) {
                                            return 7
                                        }
                                        else if (76...78 ~= item.id) {
                                            return 3
                                        }
                                        else if (94...96 ~= item.id) {
                                            return 7
                                        }
                                        else {
                                            return 1
                                        }
                                    }
                                    
                                    if (item.Letter.count > 1) {
                                        
                                        if let range = attributedString.range(of: string[1]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: colorID))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 2) {
                                        
                                        if let range = attributedString.range(of: string[2]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: colorID))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 3) {
                                        
                                        if let range = attributedString.range(of: string[3]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: colorID))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 4) {
                                        
                                        if let range = attributedString.range(of: string[4]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: colorID))
                                        }
                                    }
                                    
                                    if (item.Letter.count > 5) {
                                        
                                        if let range = attributedString.range(of: string[5]) {
                                            attributedString[range].foregroundColor = Color(hex: letterColor(id: colorID))
                                        }
                                    }
                                }
                                
                                return attributedString
                            }
                            
                            let fixedH = (mvm.lessonSelected.Number >= 11) ? false : true
                            let fixedV = (mvm.lessonSelected.Number >= 11) ? true : false
                            let lineSpacing = (mvm.lessonSelected.Number >= 11) ? 0 : (lessonLetterSize(item: item, lesson: mvm.lessonSelected) + 20)
                            
                            Text(attributedString)
                                .font(.custom("ScheherazadeNew-Regular", size: lessonLetterSize(item: item, lesson: mvm.lessonSelected)))
                                .lineSpacing(lineSpacing)
                                .foregroundColor(letterColor(item: item, activeLetter: activeLetter, lesson: mvm.lessonSelected))
                                .offset(y: letterOffset(item: item, lesson: mvm.lessonSelected) + letterPaddingTop(item: item, lesson: mvm.lessonSelected))
                                .fixedSize(horizontal: fixedH, vertical: fixedV)
                                .frame(minWidth: 150)
                                //.clipped()
                                .padding(.leading, letterPaddingStart(item: item, lesson: mvm.lessonSelected))
                                .padding(.trailing, letterPaddingEnd(item: item, lesson: mvm.lessonSelected))
                                //.padding(.top, letterPaddingTop(item: item, lesson: mvm.lessonSelected))
                                .padding(.bottom, letterPaddingBottom(item: item, lesson: mvm.lessonSelected))
                                                                                    
                            Vowel(item: $item, lesson: $mvm.lessonSelected, activeLetter: $activeLetter)
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: maxHeight)
                
                Rectangle()
                    .frame(height:1)
                    .foregroundColor(activeLetter == item.id ? colorResource.white : colorResource.ee)
                
                HStack(spacing: 0) {
                    
                    /*var trans: String {
                        
                        if (currentLanguage == "Ar") {
                            return item.Trans
                                .replacingOccurrences(of: "Beginning", with: "البداية")
                                .replacingOccurrences(of: "Middle", with: "الوسط")
                                .replacingOccurrences(of: "End", with: "النهاية")
                        }
                        else {
                            return item.Trans
                        }
                    }*/
                    
                    Text(item.Trans)
                        .font(.system(size: 18))
                        .foregroundColor(activeLetter == item.id ? colorResource.white : colorResource.maroon)
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                    if (mvm.lessonSelected.Number == 2 && !item.section) {
                        
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(colorResource.white)
                            .font(.system(size:24))
                    }
                    else {
                        
                        if (activeLetter == item.id) {
                            
                            Image(systemName: "stop.circle.fill")
                                .foregroundColor(colorResource.white)
                                .font(.system(size:24))
                        }
                        else {
                            
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(colorResource.primary_500)
                                .font(.system(size:24))
                        }
                    }
                }
                .padding(5)
                .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
                
                if (mvm.lessonSelected.Number == 7) {
                    
                    Text(item.Arti)
                        .font(.system(size: 16))
                        .foregroundColor(activeLetter == item.id ? colorResource.white : colorResource.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        .environment(\.layoutDirection, (currentLanguage == "Ar") ? .rightToLeft : .leftToRight)
                }
            }
            .alert(isPresented: $alert) {
                
                Alert(title: Text(""), message: Text("Audio file not available!"))
            }
        }
        .frame(maxWidth: .infinity)
        //.frame(width: 150)
        .background(activeLetter == item.id ? colorResource.maroon : colorResource.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color(hex: "#cacaca"), radius: (mvm.lessonSelected.Number == 2 || mvm.lessonSelected.Number == 4 || mvm.lessonSelected.Number == 17) ? 0 : 1)
        .border(colorResource.primary_200, width: (mvm.lessonSelected.Number == 2 || mvm.lessonSelected.Number == 4 || mvm.lessonSelected.Number == 17) ? 1 : 0)
        .padding(.bottom, lessonItemPaddingBottom(lesson: mvm.lessonSelected))
    }
}
