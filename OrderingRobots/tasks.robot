*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive
Library    Collections
#Library    RPA.JavaAccessBridge


*** Variables ***
${ordering_page_URL} =      https://robotsparebinindustries.com/#/robot-order
${csv_URL} =                https://robotsparebinindustries.com/orders.csv
${download_folder_path} =   C:\Users\Jan\Downloads
${csv_path} =               C:\Users\Jan\Desktop\moje\MyRobocorp\orders.csv

#Robot Page
${EntryOkBtn} =         //div[@class='alert-buttons']/button[text()='OK']
${HeadList} =           //div[@class='mb-3']/select[@id='head']
${LegFormCtrl} =        //input[@placeholder="Enter the part number for the legs"]
${AddressFormCtrl} =    //input[@name="address"]
${RobotPreview} =       //div[@id='robot-preview']
${PreviewBtn} =         //button[@id='preview']
${OrderBtn} =           //button[@id='order']
${receipt} =            //div[@id='receipt']
${OrderAnother} =       order-another



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${ordersPDF} =    Create List
    ${orders} =    Get orders
    Log   Found columns: ${orders.columns}
    Open the robot order website
    #Fill the form    ${orders}[0]    ${ordersPDF}
    #Fill the form    ${orders}[2]    ${ordersPDF}
    FOR    ${order}    IN    @{orders}
        Fill the form    ${order}    ${ordersPDF}
    END
    Zip all orders    ${ordersPDF}    ${OUTPUT_DIR}${/}ZippedOrders.zip
    Log Many    @{ordersPDF}
    Log ${ordersPDF}
    Log    Done.

    
*** Keywords ***
Open the robot order website
    Open Chrome Browser    ${ordering_page_URL}
    #Click Button    ${EntryOkBtn}
    Click Element    css=.btn-dark
    Sleep    2

Get orders
    Download    ${csv_URL}    overwrite=${True}
    ${temp_table} =    Read table from CSV    orders.csv    header=${True}
    RETURN    ${temp_table}

Fill the form
    [Arguments]    ${row}    ${ordersPdfList}
    Select From List By Index    ${HeadList}    ${row}[1]

    ${BodyIndex} =    Set Variable    ${row}[2]
    ${BodyRadioBtn} =    Set Variable    //div[@class='stacked']/div[@class='radio form-check']/label/input[@id='id-body-${BodyIndex}']
    Set Focus To Element    ${BodyRadioBtn}
    Click Element    ${BodyRadioBtn}

    ${LegIndex} =    Set Variable    ${row}[3]
    Set Focus To Element     ${LegFormCtrl}
    Input Text    ${LegFormCtrl}    ${LegIndex}

    ${AddressIndex} =    Set Variable    ${row}[4]   
    Input Text    ${AddressFormCtrl}    ${AddressIndex}

    Sleep    1
    Wait Until Keyword Succeeds    3x    1s    Click Button    ${PreviewBtn}
    Wait Until Element Is Visible    ${RobotPreview}
    
    TRY
        Wait Until Keyword Succeeds    3x    1s    Click Order
    EXCEPT
        Log    "Failed at finishing Order"
    FINALLY
        Wait Until Element Is Visible    ${receipt}    
    END

    ${pdf}=    Store the receipt as a PDF file    ${row}[0]
    ${robotPrint} =     Take a screenshot of the robot    ${row}[0]
    Embed the robot screenshot to the receipt PDF file    ${robotPrint}    ${pdf}
    Append To List    ${ordersPdfList}    ${pdf}
    Click Button   ${OrderAnother}
    Wait Until Element Is Visible    css=.btn-dark
    Click Button    css=.btn-dark
    Wait Until Element Is Visible    ${HeadList}

Click Order
    Click Button    ${OrderBtn}
    Wait Until Element Is Visible    ${receipt}

Store the receipt as a PDF file
    [Arguments]    ${orderNo}
    ${pdfPath} =    Set Variable    ${OUTPUT_DIR}${/}${orderNo}.pdf
    ${html} =    Get Element Attribute    ${receipt}    outerHTML
    Html To Pdf    ${html}    ${pdfPath}
    RETURN    ${pdfPath}


Take a screenshot of the robot
    [Arguments]    ${orderNo}
    ${pngPath} =     Set Variable    ${OUTPUT_DIR}${/}${orderNo}.png
    Screenshot    ${RobotPreview}    ${pngPath}
    RETURN    ${pngPath}

Embed the robot screenshot to the receipt PDF file
    [Arguments]  ${screenshotPath}    ${pdfPath}
    ${files} =    Create List    ${screenshotPath}
    Add Files To Pdf    ${files}    ${pdfPath}    ${True}

Zip all orders
    [Arguments]    ${listOfFiles}    ${zipPath}
    Archive Folder With Zip    ${OUTPUT_DIR}   ZippedOrders.zip