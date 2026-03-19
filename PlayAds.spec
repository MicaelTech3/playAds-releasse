# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_dynamic_libs, collect_all, collect_data_files

datas    = []
binaries = []
hiddenimports = [
    # pywebview
    'webview',
    'webview.platforms.winforms',
    'webview.platforms.edgechromium',
    # pythonnet / clr
    'clr',
    'clr_loader',
    'pythonnet',
    # áudio
    'pygame',
    'pygame.mixer',
    # pycaw
    'pycaw',
    'pycaw.pycaw',
    'pycaw.utils',
    # comtypes
    'comtypes',
    'comtypes.client',
    'comtypes.server',
    'comtypes.stream',
    # rede
    'requests',
    'urllib3',
    'certifi',
    'charset_normalizer',
    'idna',
    # yt-dlp
    'yt_dlp',
    'yt_dlp.extractor',
    'yt_dlp.downloader',
    'yt_dlp.postprocessor',
    # stdlib que pyinstaller às vezes perde
    'queue',
    'hashlib',
    'threading',
    'json',
    'logging',
    'pathlib',
]

# webview — coleta tudo (datas, binaries, hiddenimports)
tmp = collect_all('webview')
datas    += tmp[0]; binaries += tmp[1]; hiddenimports += tmp[2]

# clr_loader
tmp = collect_all('clr_loader')
datas    += tmp[0]; binaries += tmp[1]; hiddenimports += tmp[2]

# pythonnet DLLs nativas
binaries += collect_dynamic_libs('pythonnet')

# pygame — dados (sons, fontes internas)
datas += collect_data_files('pygame')

# certifi — certificados SSL necessários para requests
datas += collect_data_files('certifi')

# yt_dlp — arquivos de extratores e configurações
tmp = collect_all('yt_dlp')
datas    += tmp[0]; binaries += tmp[1]; hiddenimports += tmp[2]

a = Analysis(
    ['player.py'],
    pathex=[],
    binaries=binaries,
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # Remove módulos pesados que não usamos
        'tkinter',
        'matplotlib',
        'numpy',
        'PIL',
        'scipy',
        'pandas',
        'IPython',
        'notebook',
        'PyQt5',
        'PyQt6',
        'wx',
    ],
    noarchive=False,
    optimize=0,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='PlayAds',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['logo PlayAds.ico'],
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[
        # Não comprime DLLs do .NET — corrompe
        'clr.pyd',
        'Python.Runtime.dll',
        'python3*.dll',
    ],
    name='PlayAds',
)
