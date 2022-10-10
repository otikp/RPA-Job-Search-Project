*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Dialogs
Library     RPA.Desktop


*** Variables ***
${SEARCH_URL}       https://duunitori.fi/tyopaikat?haku=
${SEARCH_URL2}      https://www.monster.fi/tyopaikat?search= 
${SEARCH_URL3}      https://fi.indeed.com/jobs?q=


*** Tasks ***
Scraping jobs and Search for joblistings with Keywords
    ${search_query}=    Collect search query from user
    Scraping Duunitori    ${search_query}
    Scraping Monster    ${search_query}
    Scraping Indeed    ${search_query}



*** Keywords ***
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
Scraping Monster
    [Arguments]    ${search_query}
    Open Available Browser    ${SEARCH_URL2}${search_query}
    Click Element When Visible   id=almacmp-modalConfirmBtn
        ${elements}=    Get WebElements    class=gtm-search-result

    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}

        Log To Console    ${text}
    END
Scraping Indeed
    [Arguments]    ${search_query}
    Open Available Browser  ${SEARCH_URL3}${search_query}
    Click Element When Visible    id=onetrust-accept-btn-handler
        ${elements}=    Get WebElements    class=gtm-search-result

    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}

        Log To Console    ${text}
    END
