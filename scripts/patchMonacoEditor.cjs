// @ts-check

const path = require("path");
const fs = require("fs");
const crawl = require("./crawl.cjs");

function patchMonacoEditor() {
  const crawlPath = path.resolve(
    __dirname,
    "../node_modules/monaco-editor/esm"
  );

  if (!fs.existsSync(crawlPath)) {
    console.warn(`Could not find Monaco Editor path (${crawlPath})`);
    return;
  }

  const files = crawl(crawlPath, "files");

  for (const file of files) {
    const fileContents = fs.readFileSync(file, { encoding: "utf-8" });

    // https://github.com/microsoft/monaco-editor/issues/886#issuecomment-1804332159
    fileContents.replaceAll(/^import ['"].*\.css['"];$/g, "");

    fs.writeFileSync(file, fileContents);
  }

  console.log("Patched Monaco Editor");
}

patchMonacoEditor();
