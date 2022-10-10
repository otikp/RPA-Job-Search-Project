*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Dialogs
Library     RPA.Desktop


*** Variables ***
${SEARCH_URL}       https://duunitori.fi/tyopaikat?haku=
${SEARCH_URL2}      https://tyopaikat.oikotie.fi/tyopaikat?hakusana=


*** Tasks ***
Open Duunitori and Search for joblistings with Keywords
    ${search_query}=    Collect search query from user
    #Open Duunitori    ${search_query}
    Open Oikotie    ${search_query}
    Accept Cookies Oikotie
    #Accept Cookies Duunitori
    #Get joblistings


*** Keywords ***
Collect search query from user
    Add text input    search    label=Search query
    ${response}=    Run dialog
    RETURN    ${response.search}

Open Duunitori
    [Arguments]    ${search_query}
    Open Available Browser    ${SEARCH_URL}${search_query}

Open Oikotie
    [Arguments]    ${search_query}
    Open Available Browser    ${SEARCH_URL2}${search_query}

Accept Cookies Oikotie
    Click Element When Visible    class=message-component

Accept Cookies Duunitori
    Click Element When Visible    class=gdpr-close

Get joblistings
    ${elements}=    Get WebElements    class=gtm-search-result

    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}

        Log To Console    ${text}
    END
