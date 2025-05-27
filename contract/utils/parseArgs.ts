export interface DeployArgs {
  delayMs: number;
}

export const parseDeployArgs = (): DeployArgs => {
  const delayMs = process.env.DEPLOY_DELAY
    ? parseInt(process.env.DEPLOY_DELAY)
    : 20000; // Default to 20000ms if not specified

  console.log(`Using delay: ${delayMs}ms`);

  return {
    delayMs,
  };
};
