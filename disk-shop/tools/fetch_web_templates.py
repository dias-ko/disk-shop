"""Fetch only web templates from the official release ZIP via HTTP byte ranges."""
import io
import os
from pathlib import Path
import urllib.request
import zipfile

URL = 'https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz'

class RemoteZip(io.RawIOBase):
    def __init__(self):
        response = urllib.request.urlopen(urllib.request.Request(URL, method='HEAD'), timeout=45)
        self.url = response.geturl()
        self.length = int(response.headers['Content-Length'])
        self.position = 0

    def seekable(self): return True
    def readable(self): return True
    def tell(self): return self.position
    def seek(self, offset, whence=0):
        self.position = offset if whence == 0 else self.position + offset if whence == 1 else self.length + offset
        return self.position
    def read(self, size=-1):
        if size < 0: size = self.length - self.position
        if not size: return b''
        request = urllib.request.Request(self.url, headers={'Range': f'bytes={self.position}-{self.position+size-1}'})
        with urllib.request.urlopen(request, timeout=90) as response:
            if response.status != 206: raise RuntimeError('Server did not honor byte range; refusing full download')
            data = response.read()
        self.position += len(data)
        return data

destination = Path(os.environ['TEMP']) / 'disk-shop-test-appdata' / 'Godot' / 'export_templates' / '4.7.2.stable'
destination.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(RemoteZip()) as archive:
    for name in archive.namelist():
        if name.endswith(('web_nothreads_release.zip', 'web_nothreads_debug.zip', '/version.txt')):
            print('Downloading', name, flush=True)
            (destination / Path(name).name).write_bytes(archive.read(name))
print('Saved web templates to', destination)
