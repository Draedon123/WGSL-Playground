function toArrayBuffer(base64: string): ArrayBuffer {
  const binary = atob(base64);
  const length = binary.length;
  const bytes = new Uint8Array(length);

  for (let i = 0; i < length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}

function fromArrayBuffer(buffer: ArrayBuffer): string {
  let base64 = "";
  const bytes = new Uint8Array(buffer);
  const length = bytes.length;

  for (let i = 0; i < length; i++) {
    base64 += String.fromCharCode(bytes[i]);
  }

  return base64;
}

export { toArrayBuffer, fromArrayBuffer };
