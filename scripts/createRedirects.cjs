//@ts-check

const path = require("path");
const fs = require("fs");
const crawl = require("./crawl.cjs");

function createRedirects() {
  const _buildPath = process.argv[2];
  const _routesPath = process.argv[3];

  if (_buildPath === undefined) {
    throw new Error("Build path not specified");
  }

  if (_routesPath === undefined) {
    throw new Error("Routes path not specified");
  }

  const buildPath = path.resolve(__dirname, "../", _buildPath);
  const routesPath = path.resolve(__dirname, "../", _routesPath);
  const paths = crawl(routesPath, "files")
    .map((file) => file.slice(routesPath.length + 1).replace(path.sep, "/"))
    // filter out files in the root of the routes directory
    .filter((file) => file.includes("/") && file.endsWith("+page.svelte"))
    // remove file name; just leave the folder
    .map((file) => file.split("/").slice(0, -1).join("/"));

  for (const filepath of paths) {
    const redirect = `<script>
  const { protocol, host, hash } = location;
  location.href = \`\${protocol}//\${host}/WGSL-Playground/#redirect=${encodeURIComponent(filepath)}\${encodeURIComponent(hash)}\`;
</script>`;

    fs.writeFileSync(path.join(buildPath, filepath) + ".html", redirect);
    console.log(`Created redirect for path "${filepath}"`);
  }
}

createRedirects();
