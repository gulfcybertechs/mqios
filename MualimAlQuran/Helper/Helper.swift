import WebKit
import SwiftUI

func loadJson<T: Decodable>(_ filename: String) -> T {
    var data: String

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    let currentLanguage = ""

    do {
        data = try String(contentsOf: file)
        
        if (currentLanguage != "") {
            
            var langKeys: Array<String> = Array()
            
            let x = data.components(separatedBy: "\"")
            
            x.forEach { item in
                
                if (item.contains(currentLanguage)) {
                    
                    let itemKey = item.replacingOccurrences(of: currentLanguage, with: "")
                    
                    if (!langKeys.contains(itemKey)) {
                                                
                        langKeys.append(itemKey)
                    }
                }
            }
            
            langKeys.forEach { item in
                
                data = data.replacingOccurrences(of: item + "\"", with: item + "En\"")
                data = data.replacingOccurrences(of: item + currentLanguage + "\"", with: item + "\"")
            }
        }
        
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data.data(using: .utf8)!)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func instructionsSummary(value: String) -> String {

    return value.replacingOccurrences(of: "<span class=\"main-v-wrap\">", with: "")
        .replacingOccurrences(of: "<span class=\"main-v-in\">", with: "")
        .replacingOccurrences(of: "</span>", with: "")
        .replacingOccurrences(of: "<img src=\"images/alif.png\" class=\"main-v\" />", with: "ا")
        .replacingOccurrences(of: "<img src=\"images/waow.png\" class=\"main-v\" />", with: "و")
        .replacingOccurrences(of: "<img src=\"images/yaa.png\" class=\"main-v\" />", with: "ى")
        .replacingOccurrences(of: "<span class=\"main-v-in\">", with: "")
        .replacingOccurrences(of: "<img src=\"images/fatha.png\" class=\"main-v\" />", with: "َ")
        .replacingOccurrences(of: "<img src=\"images/kasra.png\" class=\"main-v\" />", with: "ِ")
        .replacingOccurrences(of: "<img src=\"images/dhamma.png\" class=\"main-v\" />", with: "ُ")
        .replacingOccurrences(of: "<img src=\"images/fatha2.png\" class=\"main-v\" />", with: "ً")
        .replacingOccurrences(of: "<img src=\"images/kasra2.png\" class=\"main-v\" />", with: "ٍ")
        .replacingOccurrences(of: "<img src=\"images/dhamma2.png\" class=\"main-v\" />", with: "ٌ")
        .replacingOccurrences(of: "<img src=\"images/alif.png\" class=\"main-v\" />", with: "ا")
        .replacingOccurrences(of: "<img src=\"images/waow.png\" class=\"main-v\" />", with: "و")
        .replacingOccurrences(of: "<img src=\"images/yaa.png\" class=\"main-v\" />", with: "ى")
        .replacingOccurrences(of: "<img src=\"images/sukoon.png\" class=\"main-v\" />", with: "ْ")
        .replacingOccurrences(of: "<img src=\"images/shadda.png\" class=\"main-v\" />", with: "ّ")
}

func listImage(name: String) -> Image {
    let uiImage =  (UIImage(named: name
        .replacingOccurrences(of: "-1", with: "_01")
        .replacingOccurrences(of: "-2", with: "_02")
    ) ?? UIImage(named: "empty"))!
   return Image(uiImage: uiImage)
}

func letterOffset(item: LessonModel, lesson: ListModel) -> CGFloat {

    var offset = 0

    //region stage 1 lesson 1
    if (lesson.StageID == 1 && (lesson.Number == 1 || lesson.Number == 2 || lesson.Number == 4 || lesson.Number == 17)) {

        if (item.id == 2 || item.sectionID == "2") {
            offset = -30
        } else if (item.id == 3 || item.id == 4 || item.sectionID == "3" || item.sectionID == "4") {
            offset = -15
        } else if (item.id == 5 || item.id == 6 || item.sectionID == "5" || item.sectionID == "6") {
            offset = -45
        } else if (item.id == 7 || item.sectionID == "7") {
            offset = -40
        } else if (item.id == 8 || item.sectionID == "8") {
            offset = -20
        } else if (item.id == 10 || item.sectionID == "10") {
            offset = -40
        } else if (item.id == 11 || item.sectionID == "11") {
            offset = -35
        } else if (item.id == 12 || item.sectionID == "12") {
            offset = -40
        } else if (item.id == 13 || item.sectionID == "13") {
            offset = -30
        } else if (item.id == 14 || item.sectionID == "14") {
            offset = -30
        } else if (item.id == 15 || item.sectionID == "15") {
            offset = -30
        } else if (item.id == 18 || item.sectionID == "18") {
            offset = -40
        } else if (item.id == 19 || item.sectionID == "19") {
            offset = -30
        } else if (item.id == 21 || item.sectionID == "21") {
            offset = -20
        } else if (item.id == 23 || item.sectionID == "23") {
            offset = -5
        } else if (item.id == 24 || item.sectionID == "24") {
            offset = -45
        } else if (item.id == 25 || item.sectionID == "25") {
            offset = -20
        } else if (item.id == 26 || item.sectionID == "26") {
            offset = -40
        } else if (item.id == 27 || item.sectionID == "27") {
            offset = -20
        } else if (item.id == 28 || item.sectionID == "28") {
            offset = -20
        } else if (item.id == 29 || item.sectionID == "29") {
            offset = -20
        } else if (item.id == 30 || item.sectionID == "30") {
            offset = -20
        }
    }
    //endregion

    //region stage 1 lesson 3
    if (lesson.StageID == 1 && lesson.Number == 3) {

        if (item.id == 4) {
            offset = 0
        }

        if (10...11) ~= item.id {
            offset = 10
        }

        if (item.id == 13) {
            offset = 20
        }

        if (item.id == 15) {
            offset = 20
        }

        if (17...18) ~= item.id  {
            offset = 0
        }

        if (29...45) ~= item.id {
            offset = -20
        }

        if (49...58) ~= item.id {
            offset = 0
        }

        if (59...61) ~= item.id {
            offset = -40
        }

        if (62...67) ~= item.id {
            offset = 0
        }

        if (70...74) ~= item.id {
            offset = 0
        }

        if (item.id == 75) {
            offset = 0
        }

        if (76...77) ~= item.id {
            offset = 0
        }

        if (80...81) ~= item.id {
            offset = 0
        }

        if (82...95) ~= item.id {
            offset = -30
        }

        if (102...108) ~= item.id {
            offset = -30
        }

        if (109...111) ~= item.id {
            offset = 0
        }

        if (119...121) ~= item.id {
            offset = 0
        }

        if (item.id == 127) {
            offset = 0
        }
    }
    //endregion

    return CGFloat(offset)
}

//func letterOffset(item: LessonModel, lesson: ListModel) -> CGFloat {
//
//    var offset = 0
//    
//    if (lesson.StageID == 1 && lesson.Number == 1) {
//        
//        if (item.id == 2) {
//            offset = -30
//        } else if (item.id == 3 || item.id == 4) {
//            offset = -15
//        } else if (item.id == 5 || item.id == 6) {
//            offset = -45
//        } else if (item.id == 7) {
//            offset = -40
//        } else if (item.id == 8) {
//            offset = -20
//        } else if (item.id == 10) {
//            offset = -40
//        } else if (item.id == 11) {
//            offset = -35
//        } else if (item.id == 12) {
//            offset = -40
//        } else if (item.id == 13) {
//            offset = -30
//        } else if (item.id == 14) {
//            offset = -30
//        } else if (item.id == 15) {
//            offset = -30
//        } else if (item.id == 18) {
//            offset = -40
//        } else if (item.id == 19) {
//            offset = -30
//        } else if (item.id == 21) {
//            offset = -20
//        } else if (item.id == 23) {
//            offset = -5
//        } else if (item.id == 24) {
//            offset = -45
//        } else if (item.id == 25) {
//            offset = -20
//        } else if (item.id == 26) {
//            offset = -40
//        } else if (item.id == 27) {
//            offset = -20
//        } else if (item.id == 28) {
//            offset = -20
//        } else if (item.id == 29) {
//            offset = -20
//        } else if (item.id == 30) {
//            offset = -20
//        }
//    }
//    
//    if (lesson.StageID == 1 && lesson.Number == 3) {
//        
//        if (item.id == 6) {
//            offset = 8
//        } else if (item.id == 10) {
//            offset = 8
//        } else if (item.id == 11) {
//            offset = 8
//        } else if (item.id == 12) {
//            offset = 8
//        } else if (item.id == 13) {
//            offset = 8
//        } else if (item.id == 15) {
//            offset = 8
//        } else if (item.id == 18) {
//            offset = 8
//        } else if (item.id == 20) {
//            offset = -10
//        } else if (item.id == 20) {
//            offset = 5
//        } else if (item.id == 22) {
//            offset = -10
//        } else if (item.id == 24) {
//            offset = 8
//        } else if (item.id == 25) {
//            offset = 8
//        } else if (item.id == 26) {
//            offset = 8
//        } else if (item.id == 27) {
//            offset = 8
//        } else if (item.id == 28) {
//            offset = 8
//        } else if (item.id == 34) {
//            offset = -30
//        } else if (item.id == 35) {
//            offset = -30
//        } else if (item.id == 36) {
//            offset = -30
//        } else if (item.id == 37) {
//            offset = -30
//        } else if (item.id == 38) {
//            offset = -30
//        } else if (item.id == 39) {
//            offset = -30
//        } else if (item.id == 40) {
//            offset = -30
//        } else if (item.id == 41) {
//            offset = -30
//        } else if (item.id == 42) {
//            offset = -30
//        } else if (item.id == 43) {
//            offset = -30
//        } else if (item.id == 44) {
//            offset = -10
//        } else if (item.id == 45) {
//            offset = -10
//        } else if (item.id == 46) {
//            offset = -10
//        } else if (item.id == 47) {
//            offset = -5
//        } else if (item.id == 48) {
//            offset = -5
//        } else if (item.id == 59) {
//            offset = -30
//        } else if (item.id == 60) {
//            offset = -30
//        } else if (item.id == 61) {
//            offset = -30
//        } else if (item.id == 82) {
//            offset = -50
//        } else if (item.id == 86) {
//            offset = -50
//        }
//    }
//        
//    return CGFloat(offset)
//}

func letterPaddingStart(item: LessonModel, lesson: ListModel) -> CGFloat {

    var padding = 5
    
    if (lesson.Number == 6 && item.id >= 29) {
        padding = 0
    }
        
    return CGFloat(padding)
}

func letterPaddingEnd(item: LessonModel, lesson: ListModel) -> CGFloat {

    var padding = 5
    
    if (lesson.Number == 6 && item.id >= 29) {
        padding = 0
    }
        
    return CGFloat(padding)
}

func letterPaddingTop(item: LessonModel, lesson: ListModel) -> CGFloat {

    var padding = 0
    
    if (lesson.Number == 2) {
        padding = 10
    }

    if (lesson.Number == 4) {
        padding = 20
    }

    if (lesson.Number == 5) {
        padding = 20
    }

    if (lesson.Number == 8) {
        padding = 0
    }

    if (lesson.Number == 10) {
        padding = 0
    }

    if (lesson.Number >= 11) {
        padding = 10
    }

    if (lesson.Number >= 13 && (item.id == 1)) {
        padding = 20
    }

    if (lesson.Number == 17) {
        padding = 20
    }
        
    return CGFloat(padding)
}

func letterPaddingBottom(item: LessonModel, lesson: ListModel) -> CGFloat {

    var padding = 0
    
    if (lesson.Number == 9) {
        padding = 20
    }

    if (lesson.Number == 5) {
        padding = 20
    }

    if (lesson.Number >= 11) {
        padding = 10
    }
        
    return CGFloat(padding)
}

func letterColor(item: LessonModel, activeLetter: Int, lesson: ListModel) -> Color {
    
    if (activeLetter == item.id) {
        
        return colorResource.white
    }
    else {
        
        if (lesson.Number == 2 || lesson.Number == 4 || lesson.Number == 17) {
            if (Int(item.sectionID) != nil) {
                return Color(hex: letterColor(id: Int(item.sectionID)!))
            }
            else {
                return Color(hex: letterColor(id: item.id))
            }
        }
        else if (lesson.Number == 5 || lesson.Number == 9 || lesson.Number == 11 || lesson.Number == 12 || lesson.Number == 13 || lesson.Number == 16) {
            
            if (item.id % 2 == 0) {
                return Color(hex: letterColor(id: 1))
            }
            else {
                return Color(hex: letterColor(id: 2))
            }
        }
        else if (lesson.Number == 6) {
            return Color(hex: letterColor(id: 2))
        }
        else if (lesson.Number == 10) {
            return Color(hex: letterColor(id: 2))
        }
        else if (lesson.Number == 15) {
            return Color(hex: letterColor(id: 2))
        }
        else {
            return Color(hex: letterColor(id: item.id))
        }
    }
}

func letterColor(id: Int) -> String {

    var _color = "#1f88cf"

    if (id > 8) {
        
        for i in stride(from: 1, to: 1000, by: 8) {

            if (id == i + 8) {
                _color = letterColorIndex(index: 1)
                break
            } else if (id == (i + 1) + 8) {
                _color = letterColorIndex(index: 2)
                break
            } else if (id == (i + 2) + 8) {
                _color = letterColorIndex(index: 3)
                break
            } else if (id == (i + 3) + 8) {
                _color = letterColorIndex(index: 4)
                break
            } else if (id == (i + 4) + 8) {
                _color = letterColorIndex(index: 5)
                break
            } else if (id == (i + 5) + 8) {
                _color = letterColorIndex(index: 6)
                break
            } else if (id == (i + 6) + 8) {
                _color = letterColorIndex(index: 7)
                break
            } else if (id == (i + 7) + 8) {
                _color = letterColorIndex(index: 8)
                break
            }
                        
        }
        
    } else {
        
        _color = letterColorIndex(index: id)
    }
    
    return _color
}

func letterColorIndex(index: Int) -> String {

    var _color = "#1f88cf"

    if (index == 1) {
        _color = "#1f88cf"
    }
    else if (index == 2) {
        _color = "#4d4d4f"
    }
    else if (index == 3) {
        _color = "#d74243"
    }
    else if (index == 4) {
        _color = "#4d4d4f"
    }
    else if (index == 5) {
        _color = "#ecaa0d"
    }
    else if (index == 6) {
        _color = "#d74243"
    }
    else if (index == 7) {
        _color = "#129b48"
    }
    else if (index == 8) {
        _color = "#ecaa0d"
    }

    return _color
}

func letterPlay(lesson: ListModel, item: LessonModel, player: Player) async -> Bool {
    
    var audioLessonNumber = String(lesson.Number)
    if (lesson.Number == 2 || lesson.Number == 7) {
        audioLessonNumber = "1"
    }

    var audioFile = String(item.id)
    if (lesson.Number == 4 || lesson.Number == 17) {
        audioLessonNumber = item.audioLesson
        audioFile = item.audioFile.description
    }
    
    let audioFileName = "00" + audioLessonNumber + "_silence_" + audioFile

    let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3")
    
    if (url != nil) {
        
        player.play(url: url!)
        
        return false
    }
    else {
                        
        return true
    }
}

func letterPlayByName(name: String, player: Player, callback: (() -> ())? = nil) {

    let audioFileName = name.replacingOccurrences(of: ".mp3", with: "")

    let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3")
        
    if (url != nil) {
        
        player.play(url: url!)
    }
}

func qLPlay(index: Int, voc: Bool = false, vocSection2: Bool = false,mvm: MainViewModel, player: Player, callback: (() -> ())? = nil) {

    Task {
        var audioFileName = "L\(mvm.lessonSelected.Number)_W\(index)"
        
        if (voc) {
            audioFileName = "V_L\(mvm.lessonSelected.Number)_W\(index)"
        }
        
        if (vocSection2) {
            audioFileName = "V1_L\(mvm.lessonSelected.Number)_W\(index)"
        }
        
        let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3")
        
        if (url != nil) {
            
            player.play(url: url!)
        }
    }
}

func letterImage(lesson: ListModel, item: LessonModel, activeLetter: Int) -> UIImage? {

    var imageID = UIImage(named: "letters_" + String(lesson.Number) + "_" + String(item.id))
    
    if (activeLetter == item.id) {
        
        let activeImageID = UIImage(named: "letters_" + String(lesson.Number) + "_" + String(item.id) + "w")
        
        if (activeImageID != nil) {
            
            imageID = activeImageID
        }
    }
    
    return imageID        
}

func toArabic(str: String) -> String {

    return str
        .replacingOccurrences(of: "0", with: "۰")
        .replacingOccurrences(of: "1", with: "۱")
        .replacingOccurrences(of: "2", with: "۲")
        .replacingOccurrences(of: "3", with: "۳")
        .replacingOccurrences(of: "4", with: "٤")
        .replacingOccurrences(of: "5", with: "٥")
        .replacingOccurrences(of: "6", with: "٦")
        .replacingOccurrences(of: "7", with: "٧")
        .replacingOccurrences(of: "8", with: "٨")
        .replacingOccurrences(of: "9", with: "٩")
}

func recitersList(download: Bool = false, mvm: MainViewModel) -> [(String, String)] {

    var data: [(String, String)] = []

    data.append(("1", "Mahmoud Al-Hussary"))
    data.append(("2", "Mohammed Al-Minshawi"))
    data.append(("3", "Ibrahim Al-Akhdar"))
    data.append(("4", "Mohammed Ayoub"))
    data.append(("5", "Mahmoud Al-Banna"))
    data.append(("6", "Mahmoud Al-Hussary with Children"))
    data.append(("7", "Mohammed Jibreel"))
    data.append(("8", "Mohammed Al-Minshawi with Children"))
    data.append(("9", "Saad Al-Ghamdi"))
    //data.append(("10", "Mohammed Faqih"))
    data.append(("11", "Ibrahim Al-Dossari (Warsh A'n Nafi')"))
    

    if (download) {
        data.append(("WordByWord", mvm.lessons.first { $0.id == 20 }!.Title.components(separatedBy: "<span>")[0]))
        data.append(("English", mvm.stages.first { $0.id == 5 }!.Title + " - English"))
        data.append(("Arabic", mvm.stages.first { $0.id == 5 }!.Title + " - Arabic"))
        data.append(("Swahili", mvm.stages.first { $0.id == 5 }!.Title + " - Swahili"))
        data.append(("French", mvm.stages.first { $0.id == 5 }!.Title + " - French"))
        data.append(("Portuguese", mvm.stages.first { $0.id == 5 }!.Title + " - Portuguese"))
        data.append(("Spanish", mvm.stages.first { $0.id == 5 }!.Title + " - Spanish"))
        data.append(("Russian", mvm.stages.first { $0.id == 5 }!.Title + " - Russian"))
        data.append(("German", mvm.stages.first { $0.id == 5 }!.Title + " - German"))
        data.append(("Hindi", mvm.stages.first { $0.id == 5 }!.Title + " - Hindi"))
        data.append(("Chinese", mvm.stages.first { $0.id == 5 }!.Title + " - Chinese"))
        data.append(("Urdu", mvm.stages.first { $0.id == 5 }!.Title + " - Urdu"))
        data.append(("Bahasa", mvm.stages.first { $0.id == 5 }!.Title + " - Bahasa"))
        data.append(("Bangla", mvm.stages.first { $0.id == 5 }!.Title + " - Bangla"))
        data.append(("Hausa", mvm.stages.first { $0.id == 5 }!.Title + " - Hausa"))
        data.append(("Turkish", mvm.stages.first { $0.id == 5 }!.Title + " - Turkish"))
    }

    return data
}

func setReciter(id: String) {

    UserDefaults.standard.set(id, forKey: "reciter")
}

func getReciter(mvm: MainViewModel) -> (String, String) {

    let recitersList = recitersList(mvm: mvm)

    let reciterName = if (UserDefaults.standard.string(forKey: "reciter") != nil) {
        recitersList.first { $0.0 == UserDefaults.standard.string(forKey: "reciter") }
    }
    else {
        recitersList[0]
    }

    return reciterName!
}

func getReciterAr(id: String) -> String {

    var name = ""

    if (id == "1") {
        name = (getLanguage() == "Ar") ? "محمود الحصري" : "Mahmoud Al-Hussary"
    } else if (id == "2") {
        name = (getLanguage() == "Ar") ? "محمد المنشاوي" : "Mohammed Al-Minshawi"
    } else if (id == "3") {
        name = (getLanguage() == "Ar") ? "إبراهيم الأخضر" : "Ibrahim Al-Akhdar"
    } else if (id == "4") {
        name = (getLanguage() == "Ar") ? "محمد أيوب" : "Mohammed Ayoub"
    } else if (id == "5") {
        name = (getLanguage() == "Ar") ?  "محمود البنا" : "Mahmoud Al-Banna"
    } else if (id == "6") {
        name = (getLanguage() == "Ar") ? "محمود الحصري مع ترديد الأطفال" : "Mahmoud Al-Hussary with Children"
    } else if (id == "7") {
        name = (getLanguage() == "Ar") ? "محمد جبريل" : "Mohammed Jibreel"
    } else if (id == "8") {
        name = (getLanguage() == "Ar") ? "محمد المنشاوي مع ترديد الأطفال" : "Mohammed Al-Minshawi with Children"
    } else if (id == "9") {
        name = (getLanguage() == "Ar") ? "سعد الغامدي" : "Saad Al-Ghamdi"
    } else if (id == "10") {
        name = (getLanguage() == "Ar") ? "محمد الفقيه" : "Mohammed Faqih"
    } else if (id == "11") {
        name = (getLanguage() == "Ar") ? "ابراهيم الدوسري (ورش عن نافع)" : "Ibrahim Al-Dossari (Warsh A'n Nafi')"
    }

    return name
}


func basmalah(surah: String, mvm: MainViewModel) -> Bool {

    return if ((mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 5) ||
        (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 6) ||
        (mvm.lessonSelected.StageID == 5 && mvm.lessonSelected.Number == 2) ||
        (mvm.lessonSelected.StageID == 3 && mvm.lessonSelected.id == 97)
    ) {
        surah != "1" && surah != "9"
    }
    else {
        false
    }
}

func basmalahScroll(vm: RecitationViewModel, ayah: Int, mvm: MainViewModel) -> Int {

    var scrollPosition = ayah

    if ((mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 5) ||
        (mvm.lessonSelected.StageID == 2 && mvm.lessonSelected.Number == 6) ||
        (mvm.lessonSelected.StageID == 5 && mvm.lessonSelected.Number == 2)
    ) {

        if (vm.surah.selected != "1" && vm.surah.selected != "9") {

            scrollPosition = ayah + 1
        }
    }

    return scrollPosition
}

func setBookmark(id: String, surah: String, surahName:String, ayah: String) {

    let format = DateFormatter()
    format.dateFormat = "dd/MM/yyyy HH:mm:ss"
    format.timeZone = TimeZone(abbreviation: "UTC")
    var currentDate = Date()
    currentDate.addTimeInterval(4 * 60)
    let date = format.string(from: currentDate)

    UserDefaults.standard.set(id, forKey: "bookmark")
    UserDefaults.standard.set(surah, forKey: "bookmarkSurah")
    UserDefaults.standard.set(surahName, forKey: "bookmarkSurahName")
    UserDefaults.standard.set(ayah, forKey: "bookmarkAyah")
    UserDefaults.standard.set(date, forKey: "bookmarkDate")

    Task {
        await pushBookmark(surah: surah, ayah: ayah)
    }
}

func getBookmark(key: String = "", mvm: MainViewModel) -> String {

    if (UserDefaults.standard.string(forKey: "bookmark\(key)") != nil) {
        
        if (key == "SurahName" && getLanguage() == "Ar") {
            
            if (!mvm.verseByVerse.isEmpty) {
                
                let data = mvm.verseByVerse
                    .filter { $0.Surah == getBookmark(key: "Surah", mvm: mvm) }
                    .sorted { Int($0.Ayah)! < Int($1.Ayah)! }
                
                return data[0].SurahNameAr.replacingOccurrences(of: data[0].SurahNameAr.split(separator: " ")[0] + " ", with: "")
            }
        }
        
        return UserDefaults.standard.string(forKey: "bookmark\(key)")!
    }
    
    return ""
    
    /*let value = if (UserDefaults.standard.string(forKey: "bookmark\(key)") != nil) {
        
        var value = UserDefaults.standard.string(forKey: "bookmark\(key)")
        
    }
    else {
        ""
    }

    return value!*/
}

func tajweedColorCode(code: Int) -> String {

    return switch (code) {
        
    case 1: "940056"
    case 2: "ed008c"
    case 3: "f48221"
    case 4: "00a652"
    case 5: "9e9fa3"
    case 6: "006f9a"
    case 7: "00adef"
    default: "940056"
    }
}

func setMemorizingAyah(id: String) {

    UserDefaults.standard.set(id, forKey: "memorizingAyah")
}

func getMemorizingAyah() -> String {

    let value = if (UserDefaults.standard.string(forKey: "memorizingAyah") != nil) {
        UserDefaults.standard.string(forKey: "memorizingAyah")
    }
    else {
        ""
    }

    return value!
}

func setMemorizingTimes(id: String) {

    UserDefaults.standard.set(id, forKey: "memorizingTimes")
}

func getMemorizingTimes() -> String {

    let value = if (UserDefaults.standard.string(forKey: "memorizingTimes") != nil) {
        UserDefaults.standard.string(forKey: "memorizingTimes")
    }
    else {
        ""
    }

    return value!
}

func setMemorizing(userID: String, surah: String, surahName: String, ayah: String, verses: String, repetitions: String, _from: String, push: Bool, date: String = "") {

    if (!isMemorized(userID: userID, surah: surah, ayah: ayah)) {

        var memorizingList = getMemorizing()

        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm:ss"
        format.timeZone = TimeZone(abbreviation: "UTC")
        var currentDate = Date()
        currentDate.addTimeInterval(4 * 60)
        var _date = format.string(from: currentDate)
        if (date != "") {
            _date = date
        }

        let item = Memorizing()
        item.UserID = userID
        item.Surah = surah
        item.SurahName = surahName
        item.Ayah = ayah
        item.Verses = verses
        item.Repetitions = repetitions
        item._From = _from
        item.Date = _date
        item.NewDate = _date
        
        memorizingList.append(item)
        
        let json = String(data: try! JSONEncoder().encode(memorizingList), encoding: String.Encoding.utf8)
        
        UserDefaults.standard.set(json, forKey: "MemorizingProgress")
        
        if (push) {
            Task {
                await pushMemorizing(type: "add", item: item)
            }
        }
    }
}

func removeMemorizing(userID: String, surah: String, ayah: String) {

    if (isMemorized(userID: userID, surah: surah, ayah: ayah)) {

        var memorizingList = getMemorizing()

        memorizingList.removeAll(where: {
            
            $0.UserID == userID && $0.Surah == surah && $0.Ayah == ayah
        })
        
        let json = String(data: try! JSONEncoder().encode(memorizingList), encoding: String.Encoding.utf8)

        UserDefaults.standard.set(json, forKey: "MemorizingProgress")
    }

    let item = Memorizing()
    item.UserID = userID
    item.Surah = surah
    item.Ayah = ayah

    Task {
        await pushMemorizing(type: "remove", item: item)
    }
}

func getMemorizing() -> [Memorizing] {

    var memorizingList: [Memorizing] = []

    let value = if (UserDefaults.standard.string(forKey: "MemorizingProgress") != nil) {
        UserDefaults.standard.string(forKey: "MemorizingProgress")
    }
    else {
        ""
    }
    
    if (value != "") {
        memorizingList = try! JSONDecoder().decode([Memorizing].self, from: value!.data(using: .utf8)!)
    }
    
    return memorizingList
}

func isMemorized(userID: String, surah: String, ayah: String) -> Bool {

    if (getMemorizing().filter {
            $0.UserID == userID &&
            $0.Surah == surah &&
            $0.Ayah == ayah
    }.count > 0) {
        return true
    }

    return false
}

func memorizingResetTotalCounter(vm: RecitationViewModel) {

    var ayahText:String {
        if (getLanguage() == "Ar") {
            "آيات"
        }
        else {
            "Ayah"
        }
    }
    
    var timesText:String {
        if (getLanguage() == "Ar") {
            "مرات"
        }
        else {
            "Times"
        }
    }
    
    if (vm.page.selected == "3 \(ayahText)" && vm.juzu.selected == "3 \(timesText)") {
        vm.memorizingTotalCounter = 15
    } else if (vm.page.selected == "5 \(ayahText)" && vm.juzu.selected == "3 \(timesText)") {
        vm.memorizingTotalCounter = 27
    } else if (vm.page.selected == "7 \(ayahText)" && vm.juzu.selected == "3 \(timesText)") {
        vm.memorizingTotalCounter = 39
    } else if (vm.page.selected == "3 \(ayahText)" && vm.juzu.selected == "5 \(timesText)") {
        vm.memorizingTotalCounter = 25
    } else if (vm.page.selected == "5 \(ayahText)" && vm.juzu.selected == "5 \(timesText)") {
        vm.memorizingTotalCounter = 45
    } else if (vm.page.selected == "7 \(ayahText)" && vm.juzu.selected == "5 \(timesText)") {
        vm.memorizingTotalCounter = 65
    } else if (vm.page.selected == "3 \(ayahText)" && vm.juzu.selected == "7 \(timesText)") {
        vm.memorizingTotalCounter = 35
    } else if (vm.page.selected == "5 \(ayahText)" && vm.juzu.selected == "7 \(timesText)") {
        vm.memorizingTotalCounter = 63
    } else if (vm.page.selected == "7 \(ayahText)" && vm.juzu.selected == "7 \(timesText)") {
        vm.memorizingTotalCounter = 91
    }
}

func memorizingResetData(vm: RecitationViewModel, data: [RecitationModel]) {

    let times = Int(vm.juzu.selected.split(separator: " ")[0])!

    var index = 0
    data.forEach({ item in
        
        if (index == 0) {
            item.memorizingCounter = times
            item.memorizingStartOverCounter = 0
        } else {
            item.memorizingCounter = times
            item.memorizingStartOverCounter = times
        }
        
        index += 1
    })
}

func setLanguage(id: String, name: String) {

    UserDefaults.standard.set(id, forKey: "language")
    UserDefaults.standard.set(name, forKey: "languageName")
}

func getLanguage() -> String {

    let value = if (UserDefaults.standard.string(forKey: "language") != nil) {
        UserDefaults.standard.string(forKey: "language")
    }
    else {
        "En"
    }

    return value!
}

func getLanguageName() -> String {

    let value = if (UserDefaults.standard.string(forKey: "languageName") != nil) {
        UserDefaults.standard.string(forKey: "languageName")
    }
    else {
        "English"
    }

    return value!
}

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

func hafs() -> String {

    if (getLanguage() == "Ar") {
        
        return "opensans"
    }

    return "KFGQPCHAFSUthmanicScript-Regula"
}
