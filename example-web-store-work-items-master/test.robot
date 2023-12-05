*** Settings ***
Library     String
Library    DateTime
Library    RequestsLibrary

*** Variables ***
${url} =    https://cloud.robocorp.com/api/v1/workspaces/3bc2c539-c0c9-41fe-a953-152a0e93ec70/work-items?process_id=daeeb0a5-7e44-4ad7-b111-1497eeafb2a3&process_run_id=a4d02f50-c790-43f1-af16-fbbe1da1a563&limit=5&state=done" --header "Authorization: RC-WSKEY zeAjyWYSckiPVtQg5zprR2mRQYHxY3Pv3ugS6ubgiY916CWwxRxg2nx58Pq42odHcAYU9SGhnW5LeYYlNXvq9D6jnLr2mwRQ3D3DtuagGAFOcgS8SFKJ6FbJIt"
${url2} =   https://api.restful-api.dev/objects  

*** Tasks ***
Testing    
    ${now} =    Get Current Date
    ${now} =    Replace String    ${now}    :    ${EMPTY}
    ${now} =    Replace String    ${now}    _    ${EMPTY}
    Log    ${now}
    
    ${response}=    GET    ${url2}
    #curl --request GET "https://cloud.robocorp.com/api/v1/workspaces/3bc2c539-c0c9-41fe-a953-152a0e93ec70/work-items?process_id=daeeb0a5-7e44-4ad7-b111-1497eeafb2a3&process_run_id=a4d02f50-c790-43f1-af16-fbbe1da1a563&limit=5&state=done" --header "Authorization: RC-WSKEY zeAjyWYSckiPVtQg5zprR2mRQYHxY3Pv3ugS6ubgiY916CWwxRxg2nx58Pq42odHcAYU9SGhnW5LeYYlNXvq9D6jnLr2mwRQ3D3DtuagGAFOcgS8SFKJ6FbJIt"
    ${str1} =    Convert To String    ${response.content}
    ${dict1}    Set Variable    ${response.json()}
    Log    ${str1}
    ${s1Type} =    Evaluate    type($str1)
    Log    Type of str1 is ${s1Type}
    ${d1Type} =    Evaluate    type($dict1)
    Log    Type of dict1 is ${d1Type}
    ${test} =    Set Variable    ${dict1}[1][name]
    Log    ${test}
