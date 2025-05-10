/// <reference types="@nomicfoundation/hardhat-ignition" />
import hre from "hardhat";
import path from "path";


import BorderlessModule from "../ignition/modules/Borderless";

async function main() {
  const { borderless } = await hre.ignition.deploy(BorderlessModule, {
    // This must be an absolute path to your parameters JSON file
    parameters: path.resolve(__dirname, "../ignition/parameters.json"),
  });

  console.log(`Apollo deployed to: ${await apollo.getAddress()}`);
}

main().catch(console.error);