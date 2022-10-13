*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Dialogs
Library     RPA.Desktop
Library     Collections
Library     RPA.Excel.Files


*** Variables ***
${SEARCH_URL}       https://duunitori.fi/tyopaikat?haku=
${SEARCH_URL2}      https://www.monster.fi/tyopaikat?search=
${SEARCH_URL3}      https://fi.indeed.com/jobs?q=
${EXECL_FILE}       Joblistings.xlsx


*** Tasks ***
Scraping jobs and Search for joblistings with Keywords
    Creating a Execl File
    ${search_query}=    Collect search query from user
    Scraping Duunitori    ${search_query}
    #Scraping Monster    ${search_query}
    #Scraping Indeed    ${search_query}    ${EXECL_FILE}


*** Keywords ***
Creating a Execl File
    Create Workbook    Joblistings.xlsx
    Save Workbook

Collect search query from user
    Add text input    search    label=Search query
    ${response}=    Run dialog
    RETURN    ${response.search}

Scraping Duunitori
    [Arguments]    ${search_query}
    Open Available Browser    ${SEARCH_URL}${search_query}
    Click Element When Visible    class=gdpr-close
    ${elements}=    Get WebElements    class=gtm-search-result

    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}

        Log To Console    ${text}
    END

    ${elements}=    Get WebElements   class=job-box__hover 
    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Log To Console    ${url}
    END
Scraping Monster
    [Arguments]    ${search_query}
    Open Available Browser    ${SEARCH_URL2}${search_query}
    Click Element When Visible    id=almacmp-modalConfirmBtn
    
    ${elements}=    Get WebElements    class= node
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Log To Console    ${text}
    END

    ${elements}=    Get WebElements   class= recruiter-job-link
    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Log To Console    ${url}
    END

Scraping Indeed
    [Arguments]    ${search_query}    ${EXECL_FILE}
    Open Workbook    ${EXECL_FILE}
    Open Available Browser    ${SEARCH_URL3}${search_query}
    Click Element When Visible    id=onetrust-accept-btn-handler

    #get links
###########################################################
    ${indeedlinks}=    Create List
    ${elements}=    Get WebElements    css:.jcs-JobTitle

    FOR    ${element}    IN    @{elements}
        ${url}=    Get Element Attribute    ${element}    href
        Append To List    ${indeedlinks}    ${url}
    END
    ${index}=    Set Variable    1
    FOR    ${element}    IN    @{indeedlinks}
        Set Cell Value    ${index}    3    ${element}
        ${index}=    Evaluate    ${index} + 1
    END
###########################################################
    ${indeedJobs}=    Create List
    ${elements}=    Get WebElements    class=jobTitle

    FOR    ${element}    IN    @{elements}
        ${job}=    Get Text    ${element}

        Append To List    ${indeedJobs}    ${job}
    END

    ${index}=    Set Variable    1
    FOR    ${element}    IN    @{indeedJobs}
        Set Cell Value    ${index}    1    ${element}
        ${index}=    Evaluate    ${index} + 1
    END
##########################################################

    ${indeedCompany}=    Create List
    ${elements}=    Get WebElements    class=companyName
    FOR    ${element}    IN    @{elements}
        ${companyname}=    Get Text    ${element}
        Append To List    ${indeedCompany}    ${companyname}
    END
    ${index}=    Set Variable    1
    FOR    ${element}    IN    @{indeedCompany}
        Set Cell Value    ${index}    2    ${element}
        ${index}=    Evaluate    ${index} + 1
    END
    Save Workbook    ${EXECL_FILE}
