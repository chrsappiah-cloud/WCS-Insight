import "dotenv/config";

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export const config = {
  port: Number(process.env.PORT ?? 8080),
  openRouterApiKey: required("OPENROUTER_API_KEY"),
  openRouterManagementKey: process.env.OPENROUTER_MANAGEMENT_KEY ?? "",
  appTitle: process.env.APP_TITLE ?? "WCS Insight",
  appUrl: process.env.APP_URL ?? "http://localhost:8080",
  defaultModel: process.env.DEFAULT_MODEL ?? "openai/gpt-4o-mini",
};
