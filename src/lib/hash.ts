function getHash(key: string, hash: string = location.hash): string | null {
  const entries = getAll(hash);

  return entries.get(key) ?? null;
}

function getAll(rawHash: string = location.hash): Map<string, string> {
  const hash = rawHash.slice(1);
  const _entries: [string, string][] = hash
    ? hash.split(",").map((entry) => {
        const [key, value] = entry.split("=").map(decodeURIComponent);

        return [key, value ?? ""];
      })
    : [];

  const entries = new Map(_entries);

  return entries;
}

function setHash(
  key: string,
  value: string,
  hash: string = location.hash
): string {
  const hashes = getAll(hash);

  hashes.set(key, value);

  return setAll(hashes);
}

function setAll(hashes: Map<string, string>): string {
  let hash = "#";

  for (const [key, value] of hashes) {
    hash += `${encodeURIComponent(key)}=${encodeURIComponent(value)},`;
  }

  // remove trailing comma
  return hash.length === 1 ? hash : hash.slice(0, -1);
}

function hasHash(key: string, hash: string = location.hash): boolean {
  const entries = getAll(hash);

  return entries.has(key);
}

export { getHash, getAll, setHash, hasHash };
