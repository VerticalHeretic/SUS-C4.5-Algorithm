//
//  DecisionTreeTableCreatorTests.swift
//  
//
//  Created by Łukasz Stachnik on 23/04/2022.
//
import XCTest

@testable import SUS

final class DecisionTreeTableCreatorTests: XCTestCase {
    let testingTableStringContent: String = """
        old,yes,swr,down
        old,no,swr,down
        old,no,hwr,down
        mid,yes,swr,down
        mid,yes,hwr,down
        mid,no,hwr,up
        mid,no,swr,up
        new,yes,swr,up
        new,no,hwr,up
        new,no,swr,up
        """

    let testingTable = [
        ["old", "yes", "swr", "down"],
        ["old", "no", "swr", "down"],
        ["old", "no", "hwr", "down"],
        ["mid", "yes", "swr", "down"],
        ["mid", "yes", "hwr", "down"],
        ["mid", "no", "hwr", "up"],
        ["mid", "no", "swr", "up"],
        ["new", "yes", "swr", "up"],
        ["new", "no", "hwr", "up"],
        ["new", "no", "swr", "up"]
    ]
    
    var creator: DecisionTreeTableCreatorImpl?
    let fileReader = LocalFileReader()
    
    override func setUp() async throws {
        creator = DecisionTreeTableCreatorImpl()
    }
    
    func testCreateDecisionsTreeTable() throws {
        guard let path = Bundle.module.path(forResource: "gielda", ofType: "txt") else {
            XCTFail()
            return
        }
        
        let contentData = try fileReader.readFile(inputFilePath: path)
        let got = try creator!.CreateDecisionsTreeTable(from: contentData)
        let want: DecisionTreeTable = DecisionTreeTable(table: testingTable)
        
        XCTAssertEqual(want, got)
    }
    
    func testDecisionTreeTableDecisionsArray() throws {
        let want: [String] = ["down","down","down","down","down", "up","up","up","up","up"]
        
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent)
        
        XCTAssertEqual(want, got.decisions)
    }
    
    func testDecisionCount() throws {
        let want = 10.0
        
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent)
        
        XCTAssertEqual(want, got.decisionsCount)
    }
    
    func testAttributes() throws {
        let want: [[String]] = [
            ["old", "yes", "swr"],
            ["old", "no", "swr"],
            ["old", "no", "hwr"],
            ["mid", "yes", "swr"],
            ["mid", "yes", "hwr"],
            ["mid", "no", "hwr"],
            ["mid", "no", "swr"],
            ["new", "yes", "swr"],
            ["new", "no", "hwr"],
            ["new", "no", "swr"]
        ]
        
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent)
        
        XCTAssertEqual(want, got.attributes)
    }
    
    func testGetRowNumbersWithAttributeOld() throws {
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent).getRowNumbersWithAttribute("old")
        let want = [0,1,2]
        
        XCTAssertEqual(got, want)
    }
    
    func testGetRowNumbersWithAttributeMid() throws {
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent).getRowNumbersWithAttribute("mid")
        let want = [3,4,5,6]
        
        XCTAssertEqual(got, want)
    }
    
    func testGetRowNumbersWithAttributeNew() throws {
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent).getRowNumbersWithAttribute("new")
        let want = [7,8,9]
        
        XCTAssertEqual(got, want)
    }
    
    func testGetDecisionsMap() throws {
        let got = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent).getDecisionsCountMapForAttribute("mid")
        let want: AttributesCountMap = ["down": 2, "up" : 2]
        
        XCTAssertEqual(got, want)
    }
    
    func testCountAttributes() throws {
        let wantAttributes: [AttributesCountMap] = [["mid": 4.0, "old": 3.0, "new": 3.0], ["yes": 4.0, "no": 6.0], ["hwr": 4.0, "swr": 6.0]]
        let attributes: [AttributesCountMap] = try creator!.CreateDecisionsTreeTable(from: testingTableStringContent).attributesCountMap
        
        XCTAssertEqual(wantAttributes, attributes)
    }
    
    func testGetAllDecisionsMap() throws {
        let table: DecisionTreeTable = DecisionTreeTable(table: testingTable)
        
        let got = table.decisionsCountMap
        let want: AttributesCountMap = ["down": 5, "up": 5]
        
        XCTAssertEqual(got, want)
    }
    
    func testGetAttributesMap() throws {
        let table: DecisionTreeTable = DecisionTreeTable(table: testingTable)
        
        let got = table.attributesCountMap
        let want: [AttributesCountMap] =
        [["old": 3, "mid": 4, "new": 3],
         ["yes" : 4, "no": 6],
         ["swr": 6, "hwr": 4]]
        
        XCTAssertEqual(got, want)
    }
    
    func testNumberOfAttributes() throws {
        var table: DecisionTreeTable = DecisionTreeTable(table: testingTable)
        var got = table.numberOfColumns
        var want: Double = 3
        XCTAssertEqual(got, want)
        
        table = DecisionTreeTable(table: [])
        got = table.numberOfColumns
        want = 0
        
        XCTAssertEqual(got, want)
    }
    
    func testGetSubTable() throws {
        let table: DecisionTreeTable = DecisionTreeTable(table: testingTable)
        let got = table.getSubTable(indexes: [3,4,5,6])
        let wantTable = [
            ["mid", "yes", "swr", "down"],
            ["mid", "yes", "hwr", "down"],
            ["mid", "no", "hwr", "up"],
            ["mid", "no", "swr", "up"],]
        
        let want = DecisionTreeTable(table: wantTable)
        
        XCTAssertEqual(got, want)
    }
    
    // MARK: Tests for big dataset (car)
    func testGetAttributesOnBigDataset() throws {
        guard let path = Bundle.module.path(forResource: "car", ofType: "data") else {
            XCTFail()
            return
        }
        let content = try fileReader.readFile(inputFilePath: path)
        let treeCreator = DecisionTreeTableCreatorImpl()
        let treeTable = try treeCreator.CreateDecisionsTreeTable(from: content)
        
        var got = treeTable.attributesCountMap[0]
        var want: AttributesCountMap = ["med": 432.0, "vhigh": 432.0, "low": 432.0, "high": 432.0]
        
        SUSLogger.shared.info("Got: \(got) want \(want)")
        XCTAssertEqual(got, want)
        
        XCTAssertEqual(treeTable.numberOfColumns, 6)
    }
}
