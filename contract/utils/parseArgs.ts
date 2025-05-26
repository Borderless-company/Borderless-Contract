export interface DeployArgs {
  delayMs: number;
}

export const parseDeployArgs = (): DeployArgs => {
  const args = process.argv.slice(2);
  const delayIndex = args.findIndex(arg => arg === '--delay');
  const delayMs = delayIndex !== -1 && args[delayIndex + 1] ? parseInt(args[delayIndex + 1]) : 20000; // Default to 20000ms if not specified

  console.log(`Using delay: ${delayMs}ms`);

  return {
    delayMs
  };
}; 