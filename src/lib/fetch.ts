import { resolve } from "$app/paths";

async function fetchText(path: string): Promise<string> {
  return (await fetch(resolve("/") + path)).text();
}

async function fetchBuffer(path: string): Promise<ArrayBuffer> {
  return (await fetch(resolve("/") + path)).arrayBuffer();
}

async function fetchBlob(path: string): Promise<Blob> {
  return (await fetch(resolve("/") + path)).blob();
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function fetchJSON(path: string): Promise<any> {
  return (await fetch(resolve("/") + path)).json();
}

export { fetchText, fetchBuffer, fetchBlob, fetchJSON };
