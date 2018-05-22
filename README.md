install-cmake
-------------
Instalador do CMake em linha de comando


# Como usar

Baixe os scripts `install-cmake.ps1` e `install-cmake.sh` e inclua em seu projeto.

## Windows

### PowerShell

```powershell
.\install-cmake.ps1 -Version "${CMAKE_VERSION}" -InstallPath "${CMAKE_INSTALL_PATH}"
```

Caso tenha problemas com a execução do script devido as políticas do `PowerShell`,
habilite a execução de scripts baixados da internet.
```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

### CMD

```sh
@powershell -NoProfile -ExecutionPolicy unrestricted ^
    .\install-cmake.ps1 -Version "%CMAKE_VERSION%" -InstallPath "%CMAKE_INSTALL_PATH%"
```

## Linux

```sh
./install-cmake.sh --version "${CMAKE_VERSION}" --install-path "${CMAKE_INSTALL_PATH}"
```

> Por enquanto somente `Windows` e `Linux`, mas posteriormente queremos evoluir para `macOS` também.
