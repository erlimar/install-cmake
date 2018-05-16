# install-cmake
Instalador do CMake em linha de comando

1. Baixe o arquivo `install-cmake.ps1`
2. Habilite a execução de scripts baixados da internet no `PowerShell`

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

3. Instale a versão do cmake em um diretório qualquer:

```powershell
.\install-cmake.ps1 -Version 3.10.3 -InstallPath "$env:UserProfile\cmake"
```

> Por enquanto somente `Windows`, mas posteriormente queremos evoluir para `Linux` e `macOS`.
