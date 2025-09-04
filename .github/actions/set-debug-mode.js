const config = await Bun.file("./config/main.lua").text();

const newFileContent = config.replace(/(\bDebugMode\s*=\s*)"[^"]*"(.*$)/gm, `$1"prod"$2`);

await Bun.write("./config/main.lua", newFileContent);
