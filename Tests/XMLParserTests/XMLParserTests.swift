import XCTest
@testable import XMLParser
import Parsing
import CustomDump


final class XMLParserTests: XCTestCase {
    func testQuotedString() throws {
        let quotedString = "\"hoi\""
        let result = try quotedStringParser.parse(quotedString)
        XCTAssertNoDifference("hoi", result)
        let printResult = try quotedStringParser.print(result)
        XCTAssertNoDifference(String(printResult), quotedString)
    }

    func testAttribute() throws {
        let attribute = "header=\"none\""
        let result = try attributeParser.parse(attribute)
        XCTAssertNoDifference(result.0, "header")
        XCTAssertNoDifference(result.1, "none")
        let printResult = try attributeParser.print(result)
        XCTAssertNoDifference(String(printResult), attribute)
    }

    func testAttributes() throws {
        let attributes = "header1=\"none\" header2=\"some\""
        let result = try attributesParser.parse(attributes)
        XCTAssertNoDifference(result["header1"], "none")
        XCTAssertNoDifference(result["header2"], "some")
        let printResult = try attributesParser.print(result)
        XCTAssertNoDifference(String(printResult), attributes)
    }

    func testTagHead() throws {
        let tagHead1 = "xmlTag header=\"none\" "
        let result1 = try tagHeadParser.parse(tagHead1)
        XCTAssertNoDifference(result1.0, "xmlTag")
        XCTAssertNoDifference(result1.1["header"], "none")

        let tagHead2 = "xmlTag "
        let result2 = try tagHeadParser.parse(tagHead2)
        XCTAssertNoDifference(result2.0, "xmlTag")
        XCTAssertNoDifference(result2.1["header"], nil)
    }

    func testEmptyTag() throws {
        let emptyTag1 = "<xmlTag header1=\"none\"/>"
        let result1 = try emptyTagParser.parse(emptyTag1)
        XCTAssertNoDifference(result1, .element("xmlTag", ["header1": "none"], []))
        let printResult1 = try emptyTagParser.print(result1)
        XCTAssertNoDifference(String(printResult1), emptyTag1)
        
        let emptyTag2 = "<xmlTag header1=\"none\" />"
        let result2 = try emptyTagParser.parse(emptyTag2)
        XCTAssertNoDifference(result2, .element("xmlTag", ["header1": "none"], []))
        let printResult2 = try emptyTagParser.print(result2)
        XCTAssertNoDifference(String(printResult2), emptyTag1)
    }

    func testOpeningTag() throws {
        let openingTag = "<xmlTag header1=\"none\">"
        let result = try openingTagParser.parse(openingTag)
        XCTAssertNoDifference(result.0, "xmlTag")
        XCTAssertNoDifference(result.1["header1"], "none")
        let printResult = try openingTagParser.print(result)
        XCTAssertNoDifference(String(printResult), openingTag)
    }

    func testContainerTag() throws {
        let containerTag = "<xmlTag headerContent=\"none\">tagContent</xmlTag>"
        let result = try containerTagParser.parse(containerTag)
        XCTAssertNoDifference(result, XML.element("xmlTag", ["headerContent": "none"], [.text("tagContent")]))
        let printResult = try containerTagParser.print(result)
        XCTAssertNoDifference(String(printResult), containerTag)
    }

    func testText() throws {
        let text = "hoi"
        let result = try textParser.parse(text)
        XCTAssertNoDifference(result, .text("hoi"))
        let printResult = try textParser.print(result)
        XCTAssertNoDifference(String(printResult), text)
    }

    func testComment() throws {
        let comment = "<!--some comments <xml in=\"between\"> endOfcomment-->"
        let result = try commentParser.parse(comment)
        XCTAssertNoDifference(result, .comment("some comments <xml in=\"between\"> endOfcomment"))
        let printResult = try commentParser.print(result)
        XCTAssertNoDifference(String(printResult), comment)
    }

    func testXMLContentText() throws {
        let body = "hoi"
        let result = try contentParser.parse(body)
        XCTAssertNoDifference(result, XML.text("hoi"))
        let printResult = try contentParser.print(result)
        XCTAssertNoDifference(String(printResult), body)
    }

    func testXMLContentComment() throws {
        let body = "<!--hoi-->"
        let result = try contentParser.parse(body)
        XCTAssertNoDifference(result, XML.comment("hoi"))
        let printResult = try contentParser.print(result)
        XCTAssertNoDifference(String(printResult), body)
    }

    func testXMLContentEmptyTag() throws {
        let tag = "<xmlTag header=\"none\"/>"
        let result = try contentParser.parse(tag)
        XCTAssertNoDifference(result, .element("xmlTag", ["header": "none"], []))
        let printResult = try contentParser.print(result)
        XCTAssertNoDifference(String(printResult), tag)
    }

    func testXMLContentContainerTag() throws {
        let containerTag = "<xmlTag headerContent=\"none\">tagContent</xmlTag>"
        let result = try contentParser.parse(containerTag)
        XCTAssertNoDifference(result, .element("xmlTag", ["headerContent": "none"], [.text("tagContent")]))
        let printResult = try contentParser.print(result)
        XCTAssertNoDifference(String(printResult), containerTag)
    }

    func testDoctype() throws {
        let doctype = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        let result = try xmlDoctypeParser.parse(doctype)
        XCTAssertNoDifference(result, .doctype(["version": "1.0", "encoding": "utf-8"]))
        let printResult = try xmlDoctypeParser.print(result)
        XCTAssertNoDifference(String(printResult), doctype)
    }

    func testXMLDoctype() throws {
        let doctype = "<?xml version=\"1.0\" encoding=\"utf-8\"?><root></root>"
        let result = try xmlParser.parse(doctype)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [])])
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), doctype)
    }

    func testXMLEmptyTag() throws {
        let xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><root><empty/></root>"
        let result = try xmlParser.parse(xml)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [.element("empty", [:], [])])])
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), xml)
    }

    func testXMLContainerTag() throws {
        let xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><root><nonEmpty>a</nonEmpty></root>"
        let result = try xmlParser.parse(xml)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [.element("nonEmpty", [:], [.text("a")])])])
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), xml)
    }

    func testXMLText() throws {
        let xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><root>text</root>"
        let result = try xmlParser.parse(xml)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [.text("text")])])
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), xml)
    }

    func testXMLComment() throws {
        let xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><root><!--comment--></root>"
        let result = try xmlParser.parse(xml)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [.comment("comment")])])
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), xml)
    }

    func testXMLNewlines() throws {
        let xml = """
        <?xml version=\"1.0\" encoding=\"utf-8\"?>
        <root>
            <nonEmpty>
                text
            </nonEmpty>
        </root>
        """
        let result = try xmlParser.parse(xml)
        XCTAssertNoDifference(result, [.doctype(["version": "1.0", "encoding": "utf-8"]), .element("root", [:], [.element("nonEmpty", [:], [.text("text")])])])
    }
}

final class XMLExampleTests: XCTestCase {
    let indentedXML = """
        <?xml version="1.0" encoding="utf-8"?>
        <Schema Namespace="microsoft.graph" Alias="graph" xmlns="http://docs.oasis-open.org/odata/ns/edm">
            <EnumType Name="appliedConditionalAccessPolicyResult">
                <Member Name="success" Value="0"/>
                <Member Name="failure" Value="1"/>
                <Member Name="notApplied" Value="2"/>
                <Member Name="notEnabled" Value="3"/>
                <Member Name="unknown" Value="4"/>
                <Member Name="unknownFutureValue" Value="5"/>
            </EnumType>
            <EnumType Name="conditionalAccessStatus">
                <Member Name="success" Value="0"/>
                <Member Name="failure" Value="1"/>
                <Member Name="notApplied" Value="2"/>
                <Member Name="unknownFutureValue" Value="3"/>
            </EnumType>
            <EnumType Name="groupType">
                <Member Name="unifiedGroups" Value="0"/>
                <Member Name="azureAD" Value="1"/>
                <Member Name="unknownFutureValue" Value="2"/>
            </EnumType>
            <EnumType Name="initiatorType">
                <Member Name="user" Value="0"/>
                <Member Name="application" Value="1"/>
                <Member Name="system" Value="2"/>
                <Member Name="unknownFutureValue" Value="3"/>
            </EnumType>
        </Schema>
        """
    let flatXML = """
        <?xml version="1.0" encoding="utf-8"?><Schema Namespace="microsoft.graph" Alias="graph" xmlns="http://docs.oasis-open.org/odata/ns/edm"><EnumType Name="appliedConditionalAccessPolicyResult"><Member Name="success" Value="0"/><Member Name="failure" Value="1"/><Member Name="notApplied" Value="2"/><Member Name="notEnabled" Value="3"/><Member Name="unknown" Value="4"/><Member Name="unknownFutureValue" Value="5"/></EnumType><EnumType Name="conditionalAccessStatus"><Member Name="success" Value="0"/><Member Name="failure" Value="1"/><Member Name="notApplied" Value="2"/><Member Name="unknownFutureValue" Value="3"/></EnumType><EnumType Name="groupType"><Member Name="unifiedGroups" Value="0"/><Member Name="azureAD" Value="1"/><Member Name="unknownFutureValue" Value="2"/></EnumType><EnumType Name="initiatorType"><Member Name="user" Value="0"/><Member Name="application" Value="1"/><Member Name="system" Value="2"/><Member Name="unknownFutureValue" Value="3"/></EnumType></Schema>
        """
    
    let structuredXML = [
        XML.doctype(["version": "1.0", "encoding": "utf-8"]),
        XML.element(
            "Schema",
            [
                "Namespace": "microsoft.graph",
                "Alias": "graph",
                "xmlns": "http://docs.oasis-open.org/odata/ns/edm"
            ], [
                .element(
                    "EnumType",
                    ["Name": "appliedConditionalAccessPolicyResult"],
                    [
                        .element("Member", ["Name": "success", "Value": "0"], []),
                        .element("Member", ["Name": "failure", "Value": "1"], []),
                        .element("Member", ["Name": "notApplied", "Value": "2"], []),
                        .element("Member", ["Name": "notEnabled", "Value": "3"], []),
                        .element("Member", ["Name": "unknown", "Value": "4"], []),
                        .element("Member", ["Name": "unknownFutureValue", "Value": "5"], [])
                    ]
                ),
                .element(
                    "EnumType",
                    ["Name": "conditionalAccessStatus"],
                    [
                        .element("Member", ["Name": "success", "Value": "0"], []),
                        .element("Member", ["Name": "failure", "Value": "1"], []),
                        .element("Member", ["Name": "notApplied", "Value": "2"], []),
                        .element("Member", ["Name": "unknownFutureValue", "Value": "3"], [])
                    ]
                ),
                .element(
                    "EnumType",
                    ["Name": "groupType"],
                    [
                        .element("Member", ["Name": "unifiedGroups", "Value": "0"], []),
                        .element("Member", ["Name": "azureAD", "Value": "1"], []),
                        .element("Member", ["Name": "unknownFutureValue", "Value": "2"], [])
                    ]
                ),
                .element(
                    "EnumType",
                    ["Name": "initiatorType"],
                    [
                        .element("Member", ["Name": "user", "Value": "0"], []),
                        .element("Member", ["Name": "application", "Value": "1"], []),
                        .element("Member", ["Name": "system", "Value": "2"], []),
                        .element("Member", ["Name": "unknownFutureValue", "Value": "3"], [])
                    ]
                ),
            ]
        )
    ]
    
    func testExample() throws {
        let result = try xmlParser.parse(indentedXML)
        XCTAssertNoDifference(
            result,
            structuredXML
        )
        let printResult = try xmlParser.print(result)
        XCTAssertNoDifference(String(printResult), flatXML)
    }
    
    func testIndentedExample() throws {
        let result = try indentedXMLParser.parse(indentedXML)
        XCTAssertNoDifference(
            result,
            structuredXML
        )
        let printResult = try indentedXMLParser.print(result)
        XCTAssertNoDifference(String(printResult), indentedXML)
    }
    
    func testFlatToIndent() throws {
        let result = try indentedXMLParser.parse(flatXML)
        XCTAssertNoDifference(
            result,
            structuredXML
        )
        let printResult = try indentedXMLParser.print(result)
        XCTAssertNoDifference(String(printResult), indentedXML)
    }
}
