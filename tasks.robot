*** Settings ***
Documentation       Use Crul queries to get product name and price data from a Shopify store
Library       CrulWrapper
Library       OperatingSystem
Library       DateTime
Library       RPA.Robocorp.Vault
Library       RPA.Tables
Library       RPA.JSON
Library       RPA.Excel.Files
Task Setup    Authorize Crul

*** Variables ***
${QUERY_FILE}            crul-query.txt
${RESULT_FILE}           output/scrape_results.xlsx
${SHEET}                 Results


*** Tasks ***
Scrape and save
    ${result}=    Scrape data with Crul    ${QUERY_FILE}
    Save to sheet    ${result}


*** Keywords ***
Scrape data with Crul
    [Arguments]    ${query_file}
    ${query}=      Get File    ${query_file}
    ${results}=    Run Query    ${query}
    ${table}=      Create Table    ${results}
    [Return]       ${table}

Save to sheet
    [Arguments]   ${data}

    TRY
        # See if there is already file existing (then append)
        Open Workbook    ${RESULT_FILE}
    EXCEPT
        # If not existing, let's create one
        Create Workbook    ${RESULT_FILE}
    END

    Append Rows To Worksheet    ${data}  header=${TRUE}
    Save Workbook

Authorize Crul
    ${secrets}=    Get Secret    Crul
    Authenticate     ${secrets}[apikey]