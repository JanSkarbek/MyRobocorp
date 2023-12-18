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
Library    RPA.Robocorp.WorkItems
Library    RPA.FileSystem


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
    Create directory     ${OUTPUT_DIR}${/}PDFs
    Open the robot order website
    TRY
        For Each Input Work Item    Fill the form
    EXCEPT    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=UNCAUGHT_ERROR
        ...    message=${err}
    END
    Zip all orders    ${OUTPUT_DIR}${/}PDFs   ZippedOrders.zip
    Log    Done.


*** Keywords ***
Open the robot order website
    Open Chrome Browser    ${ordering_page_URL}
    #Click Button    ${EntryOkBtn}
    Click Element    css=.btn-dark
    Sleep    2

Fill the form
    ${work_item}=    Get work item variables
    TRY
        IF    ${work_item}[Order number] == 7
            Click Element    id:xxx  
        END
        Select From List By Index    ${HeadList}    ${work_item}[Head]

        ${BodyIndex} =    Set Variable    ${work_item}[Body]
        ${BodyRadioBtn} =    Set Variable    //div[@class='stacked']/div[@class='radio form-check']/label/input[@id='id-body-${BodyIndex}']
        Set Focus To Element    ${BodyRadioBtn}
        Click Element    ${BodyRadioBtn}

        ${LegIndex} =    Set Variable    ${work_item}[Legs]
        Set Focus To Element     ${LegFormCtrl}
        Input Text    ${LegFormCtrl}    ${LegIndex}

        ${AddressIndex} =    Set Variable    ${work_item}[Address]   
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

    
    ${robotPrint} =     Take a screenshot of the robot    ${work_item}[Order number]
    ${pdf}=    Store the receipt as a PDF file    ${work_item}[Order number]
    Embed the robot screenshot to the receipt PDF file    ${robotPrint}    ${pdf}
    #Append To List    ${ordersPdfList}    ${pdf}
    Click Button   ${OrderAnother}
    Wait Until Element Is Visible    css=.btn-dark
    Click Button    css=.btn-dark
    Wait Until Element Is Visible    ${HeadList}
    Release Input Work Item    DONE

    EXCEPT
        Log    GENERAL ERROR   level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=UNCAUGHT_ERROR
        ...    message=GENERAL_ERROR
        Close Browser
        Sleep    1
        Open the robot order website
    END

Click Order
    Click Button    ${OrderBtn}
    Wait Until Element Is Visible    ${receipt}

Store the receipt as a PDF file
    [Arguments]    ${orderNo}
    ${pdfPath} =    Set Variable    ${OUTPUT_DIR}${/}PDFs${/}${orderNo}.pdf
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
    [Arguments]    ${FilesPath}    ${zipName}
    Log    ${FilesPath} 
    Archive Folder With Zip    ${FilesPath}    ${zipName}    include=*.pdf