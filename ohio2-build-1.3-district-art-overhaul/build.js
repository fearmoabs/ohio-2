const fs = require("fs");
const path = require("path");

const root = __dirname;
const source = (name) => fs.readFileSync(path.join(root, "src", name), "utf8").trimEnd();

let installer = source("InstallerTemplate.lua");
const replacements = {
  __ITEM_DEFINITIONS_SOURCE__: source("ItemDefinitions.lua"),
  __SERVER_MAIN_SOURCE__: source("ServerMain.lua"),
  __CLIENT_MAIN_SOURCE__: source("ClientMain.lua"),
  __VEHICLE_CONTROLLER_SOURCE__: source("VehicleController.lua"),
  __ADMIN_SERVER_SOURCE__: source("AdminServer.lua"),
  __ADMIN_CLIENT_SOURCE__: source("AdminClient.lua"),
};

for (const [placeholder, value] of Object.entries(replacements)) {
  if (!installer.includes(placeholder)) {
    throw new Error(`Missing installer placeholder: ${placeholder}`);
  }
  installer = installer.replace(placeholder, value);
}

if (/__[A-Z0-9_]+_SOURCE__/.test(installer)) {
  throw new Error("An installer source placeholder was not replaced");
}

fs.writeFileSync(path.join(root, "Ohio2_Installer.lua"), `${installer}\n`);
console.log("Built Ohio2_Installer.lua");
