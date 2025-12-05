function getHash(key: string): string | null {
  const entries = getAll();

  return entries.get(key) ?? null;
}

function getAll(): Map<string, string> {
  const hash = location.hash.slice(1);
  const _entries: [string, string][] = hash.split(",").map((entry) => {
    const [key, value] = entry.split("=").map(decodeURIComponent);

    return [key, value ?? ""];
  });

  const entries = new Map(_entries);

  return entries;
}

function setHash(key: string, value: string): void {
  const hashes = getAll();

  hashes.set(key, value);

  setAll(hashes);
}

function setAll(hashes: Map<string, string>): void {
  let hash = "";

  for (const [key, value] of hashes) {
    hash += `${encodeURIComponent(key)}=${encodeURIComponent(value)},`;
  }

  // remove trailing comma
  location.hash = hash.slice(0, -1);
}

function hasHash(key: string): boolean {
  const entries = getAll();

  return entries.has(key);
}

export { getHash, getAll, setHash, hasHash };
