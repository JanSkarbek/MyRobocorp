*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.Robocorp.WorkItems

*** Variables ***
${csv_URL} =                https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Load Work Items - Orders
     ${test} =    Set Variable    0
    IF    ${test} == 0
        ${orders} =    Get orders
        FOR    ${order}    IN    @{orders}
            Create Output Work Item    ${order}    save=${True}
        END
    ELSE
        Log    Nothing to do, just testing
    END

*** Keywords ***
Get orders
    Download    ${csv_URL}    overwrite=${True}
    ${temp_table} =    Read table from CSV    orders.csv    header=${True}
    RETURN    ${temp_table}