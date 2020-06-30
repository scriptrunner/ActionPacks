#Requires -Version 4.0

<#
    .SYNOPSIS
        The hourly updated statistic about Coronavirus. 
        Stats by country are collected from several reliable sources.
    
    .DESCRIPTION  
        

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Components needed to execute the script, e.g. Requires Module ActiveDirectory

    .LINK    
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_
        Watch our video at https://www.youtube.com/watch?v=VqlxbyWilf0 to learn how to configure the ScriptRunner Action
        https://github.com/scriptrunner/ActionPacks/tree/master/Automation%20Booster

    .Parameter RapidApiKey
        X-RapidAPI-Key. 
        Register for an API Key at https://rapidapi.com
        
    .Parameter Countries
        Names of the countries.
        Show All, shows the statistics of all countries

    .Parameter ShowTotals
        Show global totals
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RapidApiKey,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Show All','Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 
                'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 
                'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'CAR', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', "Cote d'Ivoire", 'Croatia', 'Cuba', 'Cyprus', 'Czechia', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 
                'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 
                'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 'Honduras', 'Hungary', 
                'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 
                'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 
                'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 
                'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'N. Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 
                'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 
                'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'S. Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria', 
                'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'UAE', 'UK', 'USA', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe')]
    [string[]]$Countries = @('Germany'),
    [switch]$ShowTotals
)

try{ 
    $result = @()
    [hashtable]$headers=@{
                        'x-rapidapi-host' = 'covid-19-data.p.rapidapi.com'
                        'x-rapidapi-key'  = $RapidApiKey
                        }

    [hashtable]$restparam = @{
                    Method = 'Get'
                    Headers = $headers
                }                

    if($ShowTotals -eq $true){
        $response = Invoke-RestMethod @restparam -uri 'https://covid-19-data.p.rapidapi.com/totals?format=undefined' -ErrorAction Stop
        $result += [PSCustomObject]@{
            Country = 'Total' 
            Confirmed = $response.confirmed
            Recovered = $response.recovered
            Critical = $response.critical        
            Deaths = $response.deaths
        }
    }
    
    if($Countries -contains 'Show All'){    
        $Countries = $MyInvocation.MyCommand.Parameters['Countries'].Attributes.Where{$_ -is [System.Management.Automation.ValidateSetAttribute]}.ValidValues
    }
    $uri = "https://covid-19-data.p.rapidapi.com/country?format=undefined&name={0}"
    foreach($item in $Countries) {
        if($item -like 'Show All'){
            continue
        }
        $response = Invoke-RestMethod @restparam -Uri ([System.String]::Format($uri,$item)) -ErrorAction Stop
    
        $result += [PSCustomObject]@{
                Country = $response.Country 
                Confirmed = $response.confirmed
                Recovered = $response.recovered
                Critical = $response.critical        
                Deaths = $response.deaths
            }
    }

    ConvertTo-ResultHtml -Result $result
}
catch{
    throw # throws error for ScriptRunner
}
finally{
}