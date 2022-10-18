*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Dialogs
Library     RPA.Desktop
Library     Collections
Library     RPA.Excel.Files
Library     OperatingSystem
Library     RPA.Notifier
Library     Dialogs
Library     RPA.Excel.Application    autoexit=FALSE


*** Variables ***
${SEARCH_URL}       https://duunitori.fi/tyopaikat?haku=
${SEARCH_URL2}      https://www.monster.fi/tyopaikat?search=
${SEARCH_URL3}      https://fi.indeed.com/jobs?q=
${EXECL_FILE}       Joblistings.xlsx
@{JobTitles}
@{JobLinks}


*** Tasks ***
Scraping jobs and Search for joblistings with Keywords
    Creating a Execl File
    ${search_query}=    Collect search query from user
    Create Lists    ${JobLinks}    ${JobTitles}
    Scraping Duunitori    ${search_query}    ${JobLinks}    ${JobTitles}
    Scraping Monster    ${search_query}    ${JobLinks}    ${JobTitles}
    Scraping Indeed    ${search_query}    ${JobLinks}    ${JobTitles}
    Save to Workbook    ${JobLinks}    ${JobTitles}    ${EXECL_FILE}
    Choose to open Execl    ${EXECL_FILE}
    [Teardown]    Close Browsers


*** Keywords ***
Creating a Execl File
    Create Workbook    Joblistings.xlsx
    Save Workbook

Collect search query from user
    Add text input    search    label=Search query
    ${response}=    Run dialog
    RETURN    ${response.search}

Create Lists
    [Arguments]    ${JobLinks}    ${JobTitles}
    ${JobLinks}=    Create List
    ${JobTitles}=    Create List

Scraping Duunitori
    [Arguments]    ${search_query}    ${JobLinks}    ${JobTitles}
    Open Available Browser    ${SEARCH_URL}${search_query}
    Click Element When Visible    class=gdpr-close
    Click Element When Visible    class=modal__cancel
    ${elements}=    Get WebElements    class=gtm-search-result

    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}

        Append To List    ${JobTitles}    ${text}
    END

    ${elements}=    Get WebElements    class=gtm-search-result
    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Append To List    ${JobLinks}    ${url}
    END
    Close Browser

Scraping Monster
    [Arguments]    ${search_query}    ${JobLinks}    ${JobTitles}
    Open Available Browser    ${SEARCH_URL2}${search_query}
    Click Element When Visible    id=almacmp-modalConfirmBtn

    ${elements}=    Get WebElements    class= node
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Append To List    ${JobTitles}    ${text}
    END

    ${elements}=    Get WebElements    class= recruiter-job-link

    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Append To List    ${JobLinks}    ${url}
    END
    Close Browser

Scraping Indeed
    [Arguments]    ${search_query}    ${JobLinks}    ${JobTitles}
    Open Available Browser    ${SEARCH_URL3}${search_query}
    Click Element When Visible    id=onetrust-accept-btn-handler

    ${elements}=    Get WebElements    css:.jcs-JobTitle

    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Append To List    ${JobLinks}    ${url}
    END

    ${elements}=    Get WebElements    class=jobTitle

    FOR    ${element}    IN    @{elements}
        ${job}=    Get Text    ${element}

        Append To List    ${JobTitles}    ${job}
    END
    Close Browser

Save TO Workbook
    [Arguments]    ${JobLinks}    ${JobTitles}    ${EXECL_FILE}
    RPA.Excel.Files.OpenWorkbook    ${EXECL_FILE}
    ${JobLinks}=    Remove Duplicates    ${JobLinks}
    ${index}=    Set Variable    1
    FOR    ${element}    IN    @{JobTitles}
        Set Cell Value    ${index}    1    ${element}
        ${index}=    Evaluate    ${index} + 1
    END
    ${index}=    Set Variable    1
    FOR    ${element}    IN    @{JobLinks}
        Set Cell Value    ${index}    2    =HYPERLINK("${element}","${element}")
        ${index}=    Evaluate    ${index} + 1
    END
    Save Workbook    ${EXECL_FILE}

Close Browsers
    Close All Browsers

Choose to open Execl
    [Arguments]    ${EXECL_FILE}
    Add icon    Success
    Add Heading    Open Excel?
    Add submit buttons    buttons=No,Yes    default=No
    ${result}=    Run dialog
    IF    $result.submit == "Yes"
        RPA.Excel.Application.Open Application    visible=true
        RPA.Excel.Application.Open Workbook    ${EXECL_FILE}
    END
