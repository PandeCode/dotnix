"""Pack the extension as an xpi for librewolf and a crx3 for chromium.

usage: pack.py EXTENSION_DIR KEY_PEM OUT_DIR

Chromium only installs a crx it can verify, and takes the extension id from
the signing key, so the key is fixed to keep the id. The id is printed.
"""

import hashlib
import io
import struct
import sys
import zipfile
from pathlib import Path

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding


def archive(src: Path) -> bytes:
    """Zip src with fixed timestamps, so the output is the same each build."""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(p for p in src.rglob("*") if p.is_file()):
            info = zipfile.ZipInfo(str(path.relative_to(src)), (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            zf.writestr(info, path.read_bytes())
    return buf.getvalue()


def varint(n: int) -> bytes:
    out = b""
    while n > 0x7F:
        out += bytes([n & 0x7F | 0x80])
        n >>= 7
    return out + bytes([n])


def field(number: int, data: bytes) -> bytes:
    """A length-delimited protobuf field."""
    return varint(number << 3 | 2) + varint(len(data)) + data


def crx3(zipped: bytes, key) -> tuple[bytes, str]:
    """Wrap zipped in a crx3 header signed with key, see components/crx_file."""
    public = key.public_key().public_bytes(
        serialization.Encoding.DER,
        serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    crx_id = hashlib.sha256(public).digest()[:16]
    signed_data = field(1, crx_id)

    signature = key.sign(
        b"CRX3 SignedData\x00"
        + struct.pack("<I", len(signed_data))
        + signed_data
        + zipped,
        padding.PKCS1v15(),
        hashes.SHA256(),
    )
    header = field(2, field(1, public) + field(2, signature)) + field(
        10000, signed_data
    )

    # chromium writes ids with a-p for the hex digits
    ext_id = "".join(chr(ord("a") + int(c, 16)) for c in crx_id.hex())
    return b"Cr24" + struct.pack("<II", 3, len(header)) + header + zipped, ext_id


def main() -> None:
    src, key_path, out = (Path(arg) for arg in sys.argv[1:4])
    key = serialization.load_pem_private_key(key_path.read_bytes(), password=None)

    zipped = archive(src)
    crx, ext_id = crx3(zipped, key)

    out.mkdir(parents=True, exist_ok=True)
    (out / "browser-keys.xpi").write_bytes(zipped)
    (out / "browser-keys.crx").write_bytes(crx)
    print(ext_id)


if __name__ == "__main__":
    main()
