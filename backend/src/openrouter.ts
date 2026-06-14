import { OpenRouter } from "@openrouter/sdk";
import { config } from "./config.js";

export const openRouter = new OpenRouter({
  apiKey: config.openRouterApiKey,
  httpReferer: config.appUrl,
  appTitle: config.appTitle,
});

export function managementClient(): OpenRouter {
  if (!config.openRouterManagementKey) {
    throw new Error("OPENROUTER_MANAGEMENT_KEY is required for key management routes.");
  }

  return new OpenRouter({
    apiKey: config.openRouterManagementKey,
    httpReferer: config.appUrl,
    appTitle: config.appTitle,
  });
}
