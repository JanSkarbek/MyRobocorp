*** Settings ***
Documentation    This is opening a browser and taking dump
Library    RPA.Browser.Selenium

*** Variables ***
${Akceptuje_btn} =  //div[@class='banner-actions-container']/button[@id='onetrust-accept-btn-handler']/span[text()='AKCEPTUJĘ']
${Sport_btn} =    //div[@class='navigation__mainNav']/a[@title='Sport']

*** Tasks ***
Open Browser And Take dump
    
    Open Chrome Browser    http://www.gazeta.pl
    Wait For Condition	return document.readyState == "complete"
    Wait Until Element Is Visible    ${Akceptuje_btn}    10
    Click Element    ${Akceptuje_btn}
    #Wait And Click Button    //*[text()='AKCEPTUJĘ']
    #Wait And Click Button    onetrust-accept-btn-handler
    Sleep    1
    Wait Until Element Is Visible    ${Sport_btn}    15 
    #Click Element    id:LinkArea:NavLinks2
    Click Element    ${Sport_btn}
    Sleep    5
    Screenshot
    Wait For Condition	return document.readyState == "complete"
    Wait And Click Button    onetrust-accept-btn-handler
    Close Browser
    Log    Screenshot done!


