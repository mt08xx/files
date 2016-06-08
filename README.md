# files

- wpa_passphrase.exe
 1. Download: https://w1.fi/releases/wpa_supplicant-2.5.tar.gz
 2. Open: wpa_supplicant-2.5/wpa_supplicant/vs2005/wpa_supplicant.sln with VS2015
 3. Remove the other projects from Solution.
 4. Switch to'Release'
 5. Add: "CONFIG_NO_STDOUT_DEBUG;CONFIG_CRYPTO_INTERNAL;" in
   Project property : Configuration Properties>C/C++>Preprocessor : Preprocessor Definitions
 
 6. First Build (CTRL+SHIFT+b)
 7. Patch for errors(2 places): "(args...)" => "(args,...)" 
 8. Build: wpa_supplicant-2.5/wpa_supplicant/vs2005/Release/wpa_passphrase.exe