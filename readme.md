# Things to do manually 
 - Install nerdfonts
    - download from [here](https://www.nerdfonts.com/font-downloads)
    - choose FiraMono > FiraMonoNerdFontMono-Regular
    - set as predefined for used terminal
 - Inside the lazy installation file, there is the json5 library (nvim-data/lazy/lua-json5) inside there there is a script (ps1 or sh) if an error regarding json5 is shown the script must be ran manually
 - [windows only] install chocolatey 
    ```
        @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    ```
 - install necessary packets:

    ```
    choco install lazygit
    choco install ripgrep
    choco install fd
    ```

 - remap terminal keybindings
    - fulscreen from F11 to ctrl + F11
    - copy from ctrl + c to ctrl + shift + c
    - paste from ctrl + v to ctrl + shift + v

