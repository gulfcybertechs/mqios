import Foundation

class ListModel: ObservableObject, Identifiable, Decodable {
    
    var `Type`: String = ""
    var headerID: String = ""
    var headerTitle: String = ""
    var headerSummary: String = ""
    var headerProgress: Bool = true
    var id: Int = 0
    var StageID: Int = 0
    var Number: Int = 0
    var Title: String = ""
    var Summary: String = ""
    var Title1: String = ""
    var Summary1: String = ""
    var Image: String = ""
    var Sort: Int = 0
    var isTab: Bool = false
    var TabIndex: String = ""
    var TabVisible: Bool = true
    var FromMemorizing: Bool = false
    var MemorizingSurah: String = ""
    var MemorizingSurahName: String = ""
    var MemorizingAyah: String = ""

    // These two Tajweed readers always teach with colors, without changing the saved toggle.
    var requiresTajweedColors: Bool {
        StageID == 3 && [52, 97].contains(id)
    }

    // Shared by the reader controls and the tap-to-play preference.
    var supportsRecitationReadingControls: Bool {
        StageID == 2
            || (StageID == 5 && [1, 2].contains(Number))
            || (StageID == 3 && [-1, -2].contains(Number))
    }
    
    init() {
        
    }
    
    init(isTab: Bool, TabIndex: String) {
        
        self.isTab = isTab
        self.TabIndex = TabIndex
    }  
    
    init(Title: String, TabIndex: String) {
        
        self.Title = Title
        self.TabIndex = TabIndex
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "id"
        case StageID = "StageID"
        case Number = "Number"
        case Title = "Title"
        case Summary = "Summary"
        case Title1 = "Title1"
        case Summary1 = "Summary1"
        case Image = "Image"
        case Sort = "Sort"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        StageID = try values.decodeIfPresent(Int.self, forKey: .StageID) ?? 0
        Number = try values.decodeIfPresent(Int.self, forKey: .Number) ?? 0
        Title = try values.decodeIfPresent(String.self, forKey: .Title) ?? ""
        Summary = try values.decodeIfPresent(String.self, forKey: .Summary) ?? ""
        Title1 = try values.decodeIfPresent(String.self, forKey: .Title1) ?? ""
        Summary1 = try values.decodeIfPresent(String.self, forKey: .Summary1) ?? ""
        Image = try values.decodeIfPresent(String.self, forKey: .Image) ?? ""
        Sort = try values.decodeIfPresent(Int.self, forKey: .Sort) ?? 0
    }
    
    func copy(with zone: NSZone? = nil) -> ListModel {
        let copy = ListModel()
        copy.headerID = self.headerID
        copy.headerTitle = self.headerTitle
        copy.headerSummary = self.headerSummary
        copy.headerProgress = self.headerProgress
        copy.id = self.id
        copy.StageID = self.StageID
        copy.Number = self.Number
        copy.Title = self.Title
        copy.Summary = self.Summary
        copy.Title1 = self.Title1
        copy.Summary1 = self.Summary1
        copy.Image = self.Image
        copy.Sort = self.Sort
        copy.isTab = self.isTab
        copy.TabIndex = self.TabIndex
        copy.TabVisible = self.TabVisible
        
        return copy
    }
}
