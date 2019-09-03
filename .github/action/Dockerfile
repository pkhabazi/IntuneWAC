FROM mcr.microsoft.com/powershell:latest

LABEL "com.github.actions.name"="Hello World"
LABEL "com.github.actions.description"="Write arguments to the standard output"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/pkhabazi/GithubActions"
LABEL "homepage"="https://pkm-technology.com"
LABEL "maintainer"="Pouyan Khabazi"

ADD entrypoint.ps1 /entrypoint.ps1
ENTRYPOINT ["pwsh", "/entrypoint.ps1 -ResolveDependency"]
